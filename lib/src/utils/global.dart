import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

CameraController? myCameraController;

Interpreter? classifierInterpreter;

List<String>? cashLabels;
List<String>? classifierLabels;

String cashModelPath = "assets/model/money.tflite";
String cashLabelPath = "assets/model/money.txt";

String objectModelPath = "assets/model/mobilenet.tflite";
String objectLabelPath = "assets/model/mobilenet.txt";