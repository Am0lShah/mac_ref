import SwiftUI

// MARK: - Canvas Item View

/// Renders a single image on the canvas and handles drag-to-move.
struct CanvasItemView: View {

    @ObservedObject var manager: ImageManager
    let item: CanvasImage

    // Tracks the cumulative offset while dragging
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Image(nsImage: item.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: item.size.width, height: item.size.height)
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .offset(dragOffset)
            .position(
                x: item.position.x + item.size.width  / 2,
                y: item.position.y + item.size.height / 2
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        // Commit final position into the model
                        let newPos = CGPoint(
                            x: item.position.x + value.translation.width,
                            y: item.position.y + value.translation.height
                        )
                        manager.move(id: item.id, to: newPos)
                        dragOffset = .zero
                    }
            )
            .onTapGesture {
                manager.bringToFront(id: item.id)
            }
            .contextMenu {
                Button("Remove Image", role: .destructive) {
                    manager.remove(id: item.id)
                }
            }
    }
}
