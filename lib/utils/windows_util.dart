import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:formalingua/utils/shared_util.dart';
import 'package:win32/win32.dart';

class WindowsUtil {
  static int _lastFocusedWindow = 0;
  static int _flutterWindow = 0;

  /// Copy the selected text to the clipboard.
  static Future<void> copySelectedText() async {
    // Clear the clipboard
    EmptyClipboard();
    // Simulate Ctrl+C (copy operation)
    _simulateCtrlC();
    // Add a short delay to allow the clipboard to update
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get the handle of the foreground window.
  /// Save the current Flutter window handle
  static void saveFlutterWindowHandle() {
    // window title
    const windowTitle = 'formalingua';

    // Find the window by title
    final windowTitlePointer = windowTitle.toNativeUtf16();
    _flutterWindow = FindWindow(nullptr, windowTitlePointer);

    if (_flutterWindow == 0) {
      print('Failed to find window with title: $windowTitle');
    } else {
      print('Window handle saved: $_flutterWindow');
    }

    // Free the allocated memory
    calloc.free(windowTitlePointer);
  }

  /// Method to focus on the flutter window
  static void focusFlutterWindow() {
    if (_flutterWindow != 0) {
      ShowWindow(_flutterWindow, SHOW_WINDOW_CMD.SW_RESTORE);
      SetForegroundWindow(_flutterWindow);
    } else {
      print('Flutter window handle is not set.');
    }
  }

  /// Simulate the Ctrl+V key combination to paste the copied text.
  static void simulateCtrlV() {
    // Create an array of INPUT structures
    final inputs = calloc<INPUT>(4);

    // Press Ctrl
    inputs[0].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[0].ki.wVk = VIRTUAL_KEY.VK_CONTROL; // Virtual key code for Ctrl key

    // Press V
    inputs[1].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[1].ki.wVk = VIRTUAL_KEY.VK_V; // Virtual key code for V key

    // Release V
    inputs[2].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[2].ki.wVk = VIRTUAL_KEY.VK_V;
    inputs[2].ki.dwFlags =
        KEYBD_EVENT_FLAGS.KEYEVENTF_KEYUP; // Key up flag for releasing V

    // Release Ctrl
    inputs[3].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[3].ki.wVk = VIRTUAL_KEY.VK_CONTROL;
    inputs[3].ki.dwFlags =
        KEYBD_EVENT_FLAGS.KEYEVENTF_KEYUP; // Key up flag for releasing Ctrl

    // Send the inputs
    final result = SendInput(4, inputs, sizeOf<INPUT>());
    if (result == 0) {
      print('SendInput failed with error: ${GetLastError()}');
    }

    // Free the allocated memory
    calloc.free(inputs);
  }

  /// Simulate the Ctrl+C key combination to copy the selected text.
  static void _simulateCtrlC() {
    // Create an array of INPUT structures
    final inputs = calloc<INPUT>(4);

    // Press Ctrl
    inputs[0].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[0].ki.wVk = VIRTUAL_KEY.VK_CONTROL; // Virtual key code for Ctrl key

    // Press C
    inputs[1].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[1].ki.wVk = VIRTUAL_KEY.VK_C; // Virtual key code for C key

    // Release C
    inputs[2].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[2].ki.wVk = VIRTUAL_KEY.VK_C;
    inputs[2].ki.dwFlags =
        KEYBD_EVENT_FLAGS.KEYEVENTF_KEYUP; // Key up flag for releasing C

    // Release Ctrl
    inputs[3].type = INPUT_TYPE.INPUT_KEYBOARD;
    inputs[3].ki.wVk = VIRTUAL_KEY.VK_CONTROL;
    inputs[3].ki.dwFlags =
        KEYBD_EVENT_FLAGS.KEYEVENTF_KEYUP; // Key up flag for releasing Ctrl

    // Send the inputs
    final result = SendInput(4, inputs, sizeOf<INPUT>());
    if (result == 0) {
      print('SendInput failed with error: ${GetLastError()}');
    }

    // Free the allocated memory
    calloc.free(inputs);
  }

  /// Method to focus on the last window and simulate pasting
  static void focusAndPaste() {
    if (_lastFocusedWindow != 0) {
      // Bring the last focused window to the foreground
      SetForegroundWindow(_lastFocusedWindow);
      // Simulate pasting the clipboard content into the window
      simulateCtrlV();
    } else {
      print('No window was previously focused.');
    }
  }

  /// Method to run the commands to copy and paste the text
  static Future<String> getSelectedText() async {
    // set last focused window
    _lastFocusedWindow = GetForegroundWindow();

    copySelectedText();
    // delay 150ms
    await Future.delayed(const Duration(milliseconds: 150));
    // paste the copied text
    return SharedUtil.getCopiedText();
  }

  // static String fetchWindowName() {
  //   final hwnd = GetForegroundWindow();
  //   if (hwnd == 0) return 'Invalid window handle.';

  //   final length = GetWindowTextLength(hwnd);
  //   if (length > 0) {
  //     // Allocate memory for the window text as Uint16
  //     final Pointer<Uint16> namePtr = calloc<Uint16>(length + 1);
  //     try {
  //       // Fetch the window text
  //       GetWindowText(hwnd, namePtr.cast<Utf16>(), length + 1);
  //       // Convert the Utf16 pointer to Dart String
  //       return namePtr.cast<Utf16>().toDartString(length: length);
  //     } finally {
  //       // Free the allocated memory
  //       calloc.free(namePtr);
  //     }
  //   }
  //   return 'No active window name.';
  // }
}
