import 'dart:io';
import 'dart:developer';
import 'package:text_recongnition_flutter/CustomClasses/text_recongnizer.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLKitTextRecognizer extends ITextRecongnizer {
  late TextRecognizer recognizer;

  MLKitTextRecognizer() {
    recognizer = TextRecognizer();
  }
  void dispose() {
    recognizer.close();
  }

  @override
  Future<String> processImage(String imgPath) async {
    final image = InputImage.fromFile(File(imgPath));
    final recognized = await recognizer.processImage(image);
    return recognized.text;
  }

  Future<void> processImageInBlocks(InputImage image) async {
    final recognized = await recognizer.processImage(image);
    final blocks = recognized.blocks;
    for (int i = 0; i < blocks.length; i++) {
      final e = blocks[i];
      log("Block number $i");
      log(e.text);
    }
  }
}
