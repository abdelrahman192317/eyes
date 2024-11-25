import 'package:flutter/material.dart';
import '../classifier/classifier.dart';
import '../utils/camera.dart';

class CashCamera extends CameraApp {
  const CashCamera({super.key});

  @override
  CashCameraState createState() => CashCameraState();
}

class CashCameraState extends CameraAppState {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initController,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done?
       GestureDetector(
         excludeFromSemantics: true,
         onTap: () {
          //classifier
          captureImage().then((imagePath) {
            Classifier.classifyImage(imagePath);
          });
        },
         onDoubleTap: () {
            //cash recognition
             captureImage().then((imagePath) {
               Classifier.classifyCashImage(imagePath);
             });
           },
          child: const CameraApp()
       ) :
      const Center(child: CircularProgressIndicator())
    );
  }
}
