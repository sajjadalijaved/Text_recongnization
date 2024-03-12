import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_recongnition_flutter/Widgets/image_picker_dialog.dart';
import 'package:text_recongnition_flutter/CustomClasses/text_recongnizer.dart';
import 'package:text_recongnition_flutter/CustomClasses/tesseract_text_recognizer.dart';
import 'package:text_recongnition_flutter/CustomClasses/mlkittext_recognizer_class.dart';
import 'package:text_recongnition_flutter/CustomClasses/recognition_response_class.dart';

// ignore_for_file: use_build_context_synchronously

class ImageToText1 extends StatefulWidget {
  const ImageToText1({super.key});

  @override
  State<ImageToText1> createState() => _ImageToText1State();
}

class _ImageToText1State extends State<ImageToText1> {
  late ImagePicker picker;
  late ITextRecongnizer recongnizer;
  RecognitionResponse? response;

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();

    // recongnizer = MLKitTextRecognizer();
    recongnizer = TesseractTextRecognizer();
  }

  @override
  void dispose() {
    if (recongnizer is MLKitTextRecognizer) {
      (recongnizer as MLKitTextRecognizer).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text Recongition"),
      ),
      body: response == null
          ? const Center(
              child: Text("Pick image to continue"),
            )
          : ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).width,
                  width: MediaQuery.sizeOf(context).width,
                  child: Image.file(File(response!.imgPath)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(
                            "Recognized Text",
                            style: Theme.of(context).textTheme.titleLarge,
                          )),
                          CupertinoButton(
                              minSize: 0,
                              padding: EdgeInsets.zero,
                              child: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: response!.recognizedText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Copied to Clipboard')));
                              })
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(response!.recognizedText),
                    ],
                  ),
                )
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => imagePickerAlert(onCameraPressed: () async {
                    final imagePath = await obtainImage(ImageSource.camera);
                    if (imagePath == null) return;
                    Navigator.of(context).pop();
                    processImage(imagePath);
                  }, onGalleryPressed: () async {
                    final imagePath = await obtainImage(ImageSource.gallery);
                    if (imagePath == null) return;
                    Navigator.of(context).pop();
                    processImage(imagePath);
                  }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // functions
  // get image function
  Future<String?> obtainImage(ImageSource source) async {
    final file = await picker.pickImage(source: source);
    return file?.path;
  }

  // process image function
  void processImage(String imgPath) async {
    final recognizedText = await recongnizer.processImage(imgPath);
    setState(() {
      response =
          RecognitionResponse(imgPath: imgPath, recognizedText: recognizedText);
    });
  }
}
