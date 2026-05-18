# MacRef

A lightweight, always-on-top image reference board for macOS — inspired by PureRef and BeeRef.

- Borderless dark canvas that floats above all windows
- Drag & drop images from Finder
- Rearrange images freely on the canvas
- 100% offline · No dependencies · Native Swift/SwiftUI

## Installation

When you download the app artifacts, you will see both a `.dmg` and a `.pkg`.

**Recommended Installation (Avoids "App is damaged" error):**
1. Download the **MacRef.pkg**.
2. **Right-click** on `MacRef.pkg` and select **Open** (Do NOT just double-click).
3. If macOS warns you about an unidentified developer, click **Open** again.
4. Follow the installer steps. It will place the app into your `/Applications` folder perfectly without Gatekeeper quarantine errors.

*Alternative (DMG)*: If you use the `.dmg`, after dragging the app to Applications, macOS might say "App is damaged" because it's not signed with a paid Apple Developer account. To fix this, open Terminal and run: `xattr -cr /Applications/MacRef.app`

## Build

This project uses [GitHub Actions](https://github.com/features/actions) to build automatically on a free macOS runner.
Push to `main` → `.dmg` and `.pkg` appears under **Actions → Artifacts** in ~3–4 minutes.
