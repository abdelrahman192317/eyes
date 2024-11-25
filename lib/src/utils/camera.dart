import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'global.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  CameraAppState createState() => CameraAppState();
}

class CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  Future<void>? initController;
  var isCameraReady = false;

  @override
  void initState() {
    initCamera();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initController = myCameraController!.initialize();
    }
    if (!mounted) return;
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    /// scale to fit the device size
    var scale = size.width / size.height * myCameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: scale,
                child: CameraPreview(myCameraController!),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'tap for object Detection',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: size.height * 0.1),
                  const Text(
                    'double tap for Cash recognition',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            )
          ]
      ),
    );
  }

  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    initController = myCameraController!.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        isCameraReady = true;
      });
    });
  }

  Future<String> captureImage() async {
    XFile file = await myCameraController!.takePicture();
    return file.path;
  }
}
