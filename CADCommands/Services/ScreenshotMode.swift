import Foundation

enum ScreenshotMode {
    static var isExporting: Bool {
        ProcessInfo.processInfo.arguments.contains("-ExportScreenshots")
    }

    static var unlockPro: Bool {
        isExporting || ProcessInfo.processInfo.arguments.contains("-UnlockPro")
    }
}
