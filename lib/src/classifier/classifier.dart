import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite/tflite.dart' as cash_model;

import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/global.dart';
import '../utils/media_player.dart';

class Classifier {

  static void loadCashModel() async {
    await cash_model.Tflite.loadModel(model: cashModelPath, labels: cashLabelPath);
  }

  static void classifyCashImage(String imagePath) async {

    var output = await cash_model.Tflite.runModelOnImage(
        path: imagePath, numResults: 2, threshold: 0.1,
        imageMean: 127.5, imageStd: 127.5, asynch: true
    );

    if (output!.isNotEmpty) {
      String result = output[0]["label"];
      MediaPlayer.speak(result.substring(2));
    }else {
      MediaPlayer.speak('Can\'t Recognize');
    }

  }

  static Future<void> loadClassifierModel() async {
    classifierInterpreter = await getInterpreter(modelPath: objectModelPath);
    classifierLabels = await getLabels(labelPath: objectLabelPath);
  }

  static Future<List<dynamic>?> classifyImage(String imagePath) async {

    // Get tensor input shape [1, image]
    Tensor inputTensor = classifierInterpreter!.getInputTensors().first;
    debugPrint(inputTensor.toString());
    // Get tensor output shape [1, respond]
    Tensor outputTensor = classifierInterpreter!.getOutputTensors().first;
    debugPrint(outputTensor.toString());

    image_lib.Image? image;
    List<int> inputShape = inputTensor.shape;
    List<int> outputShape = outputTensor.shape;

    final imageData = File(imagePath).readAsBytesSync();
    debugPrint('after read image');

    // Decode image using package:image/image.dart
    image = image_lib.decodeImage(imageData);
    debugPrint('after decode image');

    // resize original image to match model shape.
    image_lib.Image imageInput = image_lib.copyResize(
      image!,
      width: inputShape[1],
      height: inputShape[2],
    );
    debugPrint('after resize image');

    final imageMatrix = List.generate(
      imageInput.height, (y) => List.generate(
        imageInput.width, (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );
    debugPrint('after image matrix');

    // Set tensor input [1, 224, 224, 3]
    final input = [imageMatrix];

    final output = [List<int>.filled(outputShape[1], 0)];

    // Run inference and get the output
    classifierInterpreter!.run(input, output);

    debugPrint('after run');

    printOutputs(output: output, labels: classifierLabels!);

    return output;
  }

  static Future<Interpreter> getInterpreter({required String modelPath}) async {

    Interpreter interpreter;

    interpreter = await Interpreter.fromAsset(modelPath,
        options: InterpreterOptions()..addDelegate(XNNPackDelegate()));

    debugPrint('\n\ninput shape: ${interpreter.getInputTensor(0).shape}');
    debugPrint('output shape: ${interpreter.getOutputTensor(0).shape}');
    debugPrint('input type: ${interpreter.getInputTensor(0).type}');
    debugPrint('output type: ${interpreter.getOutputTensor(0).type}\n\n');

    return interpreter;

  }

  static Future<List<String>> getLabels({required String labelPath}) async {

    List<String> labels;

    debugPrint('before labels');
    final labelTxt = await rootBundle.loadString(labelPath);
    labels = labelTxt.split('\n');
    debugPrint("labels: ${labels.toString()}");

    return labels;

  }

  static printOutputs({required output, required List labels}) {

    final result = output.first;

    var maxScore = result.reduce((a, b) => (a as int) + (b as int));

    debugPrint("maxScore: $maxScore");

    // Set classification map {label: points}
    var classification = <String, double>{};
    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points
        classification[labels[i]] = result[i].toDouble() / maxScore.toDouble();
      }
    }

    debugPrint("classification: $classification");

    debugPrint("classification length: ${classification.length}");

    var values = classification.values.toList()..sort((a, b) => a.compareTo(b));
    var keys = classification.keys.toList();

    String className = keys[classification.values.toList().indexOf(values.last)];

    debugPrint("classification max: $className");

    debugPrint("classification: $classification");

    MediaPlayer.speak(className);

  }
}
