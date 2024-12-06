import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:formalingua/widgets/text_transformer.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Transformer',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Text Transformer'),
        ),
        body: const TextTransformerWidget(),
      ),
    );
  }
}
