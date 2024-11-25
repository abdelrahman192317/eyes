import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

import '../utils/global.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    initCameraController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedSplashScreen(
      duration: 1000,
      splashIconSize: size.height,
      splash: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            SizedBox(
              width: size.width ,height: size.height,
              child: Image.asset('assets/logo.png', fit: BoxFit.cover,)),
            Align(
              alignment: Alignment.bottomCenter,
              child: SpinKitFadingCircle(
                color: Colors.lightBlueAccent,
                size: size.height * 0.12,
              ),
            ),
          ],
        ),
      ),
      nextScreen: const HomeScreen(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }

  Future<void> initCameraController() async {
    final cameras = await availableCameras();
    myCameraController = CameraController(cameras[0], ResolutionPreset.medium);
  }
}