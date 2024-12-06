import 'package:formalingua/interfaces/llm_service.dart';

class DummyService implements LLMService {

  @override
  Future<String> generateUpdatedText(String prompt, String originalText) async {
    return 'Response: $prompt\nOriginal Text:\n$originalText';
  }
}
