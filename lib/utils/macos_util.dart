import 'package:flutter/services.dart';

class MacOSUtil {
  static const MethodChannel _channel = MethodChannel('formalingua/macos');

  static Future<void> copySelectedText() async {
    await _channel.invokeMethod<void>('copySelectedText');
  }

  static Future<void> pasteText() async {
    await _channel.invokeMethod<void>('pasteText');
  }
}