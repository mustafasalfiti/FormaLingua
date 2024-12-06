import 'package:flutter/services.dart';

class SharedUtil {
  final List<String> prompts = [
    "Please update the text with better grammar and formatting.",
    "Summarize the following text.",
    "Translate the following text to Spanish.",
    "Rewrite the text to make it more formal.",
    "Simplify the text for a younger audience."
  ];

  final List<String> currentLLMModel = ['Dummy', 'OpenAI'];

  static void copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String> getCopiedText() async {
    final clipboardData = await Clipboard.getData('text/plain');
    return clipboardData?.text ?? '';
  }
}
