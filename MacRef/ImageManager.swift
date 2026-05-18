import SwiftUI
import UniformTypeIdentifiers
import AppKit

// MARK: - Model

/// Represents a single image placed on the canvas.
struct CanvasImage: Identifiable {
    let id: UUID
    var image: NSImage
    var position: CGPoint          // top-left origin in canvas coordinates
    var size: CGSize               // current display size

    init(image: NSImage, position: CGPoint) {
        self.id       = UUID()
        self.image    = image
        self.position = position

        // Scale image to a sensible default width, preserving aspect ratio
        let maxWidth: CGFloat = 320
        let ratio = image.size.width > 0 ? maxWidth / image.size.width : 1
        self.size = CGSize(
            width:  image.size.width  * ratio,
            height: image.size.height * ratio
        )
    }
}

// MARK: - Manager

/// The single source of truth for all images on the canvas.
@MainActor
final class ImageManager: ObservableObject {

    @Published private(set) var images: [CanvasImage] = []

    // MARK: Add

    /// Add images from file URLs (called after drag-and-drop validation).
    func addImages(from urls: [URL], dropPoint: CGPoint) {
        let validTypes: Set<UTType> = [.png, .jpeg, .tiff, .bmp, .gif, .heic, .webP]

        var xOffset: CGFloat = 0
        for url in urls {
            guard
                let uti   = UTType(filenameExtension: url.pathExtension),
                validTypes.contains(uti),
                let nsImg = NSImage(contentsOf: url)
            else { continue }

            let pos = CGPoint(x: dropPoint.x + xOffset, y: dropPoint.y)
            let entry = CanvasImage(image: nsImg, position: pos)
            images.append(entry)
            xOffset += entry.size.width + 12   // cascade each image slightly
        }
    }

    // MARK: Move

    /// Update position of an image (called during drag gesture).
    func move(id: UUID, to newPosition: CGPoint) {
        guard let idx = images.firstIndex(where: { $0.id == id }) else { return }
        images[idx].position = newPosition
    }

    // MARK: Bring to Front

    /// Move the tapped image to the top of the Z-stack.
    func bringToFront(id: UUID) {
        guard let idx = images.firstIndex(where: { $0.id == id }) else { return }
        let item = images.remove(at: idx)
        images.append(item)
    }

    // MARK: Remove

    func remove(id: UUID) {
        images.removeAll { $0.id == id }
    }

    func clear() {
        images.removeAll()
    }
}
