import 'package:flutter/material.dart';

import '../classifier/classifier.dart';
import 'cash_camera.dart';
import '../utils/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    Classifier.loadCashModel();
    Classifier.loadClassifierModel();
    super.initState();
  }

  @override
  void dispose() {
    myCameraController!.dispose();
    classifierInterpreter!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: CashCamera()
    );
  }
}
