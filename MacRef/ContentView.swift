import SwiftUI
import UniformTypeIdentifiers

// MARK: - Drop Delegate

/// Handles Finder → Canvas drag-and-drop.
struct CanvasDropDelegate: DropDelegate {

    let manager: ImageManager
    let canvasSize: CGSize

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.fileURL])
    }

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: [.fileURL])
        guard !providers.isEmpty else { return false }

        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                if let data = item as? Data,
                   let url  = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            // Convert from SwiftUI's flipped coordinate system
            let dropPoint = CGPoint(
                x: info.location.x,
                y: info.location.y
            )
            manager.addImages(from: urls, dropPoint: dropPoint)
        }
        return true
    }
}

// MARK: - ContentView

struct ContentView: View {

    @StateObject private var manager = ImageManager()

    // Canvas background color — near-black charcoal
    private let canvasBG = Color(red: 0.13, green: 0.13, blue: 0.14)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background ──────────────────────────────────────────────
                canvasBG
                    .ignoresSafeArea()

                // ── Empty-state hint ────────────────────────────────────────
                if manager.images.isEmpty {
                    emptyStateOverlay
                }

                // ── Canvas images ───────────────────────────────────────────
                ForEach(manager.images) { item in
                    CanvasItemView(manager: manager, item: item)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Accept file drops from Finder
            .onDrop(
                of: [.fileURL],
                delegate: CanvasDropDelegate(
                    manager: manager,
                    canvasSize: geo.size
                )
            )
            // Toolbar / context menu for the whole canvas
            .contextMenu {
                if !manager.images.isEmpty {
                    Button("Clear All", role: .destructive) {
                        manager.clear()
                    }
                }
                Button("Close Window") {
                    NSApplication.shared.windows.first?.close()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Empty-state

    private var emptyStateOverlay: some View {
        VStack(spacing: 14) {
            Image(systemName: "photo.stack")
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Drop Images Here")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.55))

            Text("Drag & drop images from Finder\nRight-click for options")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.28))
        }
        .allowsHitTesting(false)   // pass events through to the canvas
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .frame(width: 900, height: 700)
}
