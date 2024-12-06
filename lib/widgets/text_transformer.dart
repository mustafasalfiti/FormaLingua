import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formalingua/interfaces/llm_service.dart';
import 'package:formalingua/services/dummy_service.dart';
import 'package:formalingua/services/openapi_service.dart';
import 'package:formalingua/utils/shared_util.dart';
import 'package:formalingua/utils/windows_util.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextTransformerWidget extends StatefulWidget {
  const TextTransformerWidget({super.key});

  @override
  State<TextTransformerWidget> createState() => _TextTransformerWidgetState();
}

class _TextTransformerWidgetState extends State<TextTransformerWidget> {
  /// The API key for the OpenAI service
  String _apiKey = '';

  /// The selected prompt
  String selectedPrompt = '';

  /// The AI service
  late LLMService _llmService;

  /// The text controllers for the original and updated text
  late TextEditingController _originalTextController;

  /// The text controllers for the original and updated text
  late TextEditingController _updatedTextController;

  /// The list of prompts
  final List<String> prompts = SharedUtil().prompts;

  /// The list of AI services
  final List<String> llmServices = SharedUtil().currentLLMModel;

  /// paste the clipboard text automatically
  bool _pasteAutomatically = false;

  String selectedLLMService = SharedUtil().currentLLMModel[0];

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows) {
      WindowsUtil.initFlutterWindow();
    }

    _registerHotKey();

    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    _originalTextController = TextEditingController();
    _updatedTextController = TextEditingController();

    _loadselectedLLMService();
    _loadSelectedPrompt();
  }

  /// Register the hot key to paste the clipboard text
  Future<void> _registerHotKey() async {
    await hotKeyManager.register(
      HotKey(
          key: PhysicalKeyboardKey.keyN, modifiers: [HotKeyModifier.control]),
      keyDownHandler: (hotKey) async {
        if (Platform.isWindows) {
          print('Hot key pressed: Ctrl+N');
          final selectedText = await WindowsUtil.getSelectedText();
          _updateTextController(selectedText);
          if (_pasteAutomatically) {
            _transformText();
            /// delay 150ms
            await Future.delayed(const Duration(milliseconds: 150));
            WindowsUtil.simulateCtrlV();
          } else {
            WindowsUtil.focusFlutterWindow();
          }
        } else {
          print('Paste operation is not supported on this platform');
        }
      },
    );
  }

  /// update the text controller with the selected text
  void _updateTextController(String selectedText) {
    setState(() {
      _originalTextController.text = selectedText;
    });
  }

  /// Transform the text using the selected AI service
  Future<void> _transformText() async {
    setState(() {});

    String updatedText = await _llmService.generateUpdatedText(
        selectedPrompt, _originalTextController.text);

    setState(() {
      _updatedTextController.text = updatedText;
    });
    SharedUtil.copyToClipboard(updatedText);
  }

  /// Focus the previously active window and paste the content
  _focusAndPaste() {
    if (Platform.isWindows) {
      WindowsUtil.focusAndPaste();
    } else {
      print('Paste operation is not supported on this platform');
    }
  }

  /// Load the selected AI service
  Future<void> _loadselectedLLMService() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLLMService =
          prefs.getString('selectedLLMService') ?? llmServices[0];
      _initializeLLMService();
    });
  }

  /// Save the selected prompt
  Future<void> _saveSelectedPrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPrompt', prompt);
  }

  /// Save and load the selected LLM service and prompt
  Future<void> _saveSelectedLLMService(String aiService) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLLMService', aiService);
  }

  /// Load the selected prompt
  Future<void> _loadSelectedPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPrompt = prefs.getString('selectedPrompt') ?? prompts[0];
    });
  }

  /// Initialize the selected AI service
  void _initializeLLMService() {
    if (selectedLLMService == "Dummy") {
      _llmService = DummyService();
    } else if (selectedLLMService == "OpenAI") {
      _llmService = OpenAIService(_apiKey);
    }
    // Add other AI service initializations here
  }

  /// Dispose the text controllers and unregister hot keys
  @override
  void dispose() {
    _originalTextController.dispose();
    _updatedTextController.dispose();
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPrompt.isNotEmpty ? selectedPrompt : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Operation',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select a prompt'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPrompt = newValue!;
                      _saveSelectedPrompt(selectedPrompt);
                    });
                  },
                  items: prompts.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value:
                      selectedLLMService.isNotEmpty ? selectedLLMService : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Model',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select a Model'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLLMService = newValue!;
                      _initializeLLMService();
                      _saveSelectedLLMService(selectedLLMService);
                    });
                  },
                  items:
                      llmServices.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Paste Automatically Checkbox
          Row(
            children: [
              Checkbox(
                value: _pasteAutomatically,
                onChanged: (bool? value) {
                  setState(() {
                    _pasteAutomatically = value!;
                  });
                },
              ),
              const Text('Paste Automatically'),
            ],
          ),

          const SizedBox(height: 16),
          // Original Text Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _originalTextController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Original Text',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Generated Text Display
              Expanded(
                child: TextField(
                  readOnly: true,
                  maxLines: 8,
                  controller: _updatedTextController,
                  decoration: const InputDecoration(
                    labelText: 'Generated Text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Transform Button
          Center(
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Focus the previously active window and paste the content
                    _transformText();
                  },
                  child: const Text('Transform Text'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Focus the previously active window and paste the content
                    _focusAndPaste();
                  },
                  child: const Text('Paste'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
