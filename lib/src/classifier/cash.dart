
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;

import '../utils/global.dart';
import '../utils/media_player.dart';

class Cash {

  static Future<void> loadCashModel() async {
    cashInterpreter = await getInterpreter(modelPath: cashModelPath);
    cashLabels = await getLabels(labelPath: cashLabelPath);
  }

  static Future<List<dynamic>?> classifyCashImage(String imagePath) async {

    // Get tensor input shape [1, image]
    Tensor inputTensor = cashInterpreter!.getInputTensors().first;
    debugPrint(inputTensor.toString());
    // Get tensor output shape [1, respond]
    Tensor outputTensor = cashInterpreter!.getOutputTensors().first;
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

    final output = [List<double>.filled(outputShape[1], 0)];

    // Run inference and get the output
    cashInterpreter!.run(input, output);

    debugPrint('after run');

    printOutputs(output: output, labels: cashLabels!);

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

    var maxScore = result.reduce((a, b) => (a as double) + (b as double));

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

    var values = classification.values.toList()
      ..sort((a, b) => a.compareTo(b));
    var keys = classification.keys.toList();

    String className = keys[classification.values.toList().indexOf(
        values.last)];

    debugPrint("classification max: $className");

    debugPrint("classification: $classification");

    MediaPlayer.speak(className);
  }

}
