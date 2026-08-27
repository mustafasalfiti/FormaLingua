import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var sourceApplication: NSRunningApplication?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let channel = FlutterMethodChannel(
      name: "formalingua/macos",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "copySelectedText":
        self?.sourceApplication = NSWorkspace.shared.frontmostApplication
        Self.postCommandKey(keyCode: 8)
        result(nil)
      case "pasteText":
        self?.sourceApplication?.activate(options: [.activateIgnoringOtherApps])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
          Self.postCommandKey(keyCode: 9)
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private static func postCommandKey(keyCode: CGKeyCode) {
    guard let keyDown = CGEvent(
      keyboardEventSource: nil,
      virtualKey: keyCode,
      keyDown: true
    ), let keyUp = CGEvent(
      keyboardEventSource: nil,
      virtualKey: keyCode,
      keyDown: false
    ) else {
      return
    }

    keyDown.flags = .maskCommand
    keyUp.flags = .maskCommand
    keyDown.post(tap: .cghidEventTap)
    keyUp.post(tap: .cghidEventTap)
  }
}
