import 'package:flutter/material.dart';

import '../classifier/cash.dart';
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
  void initState(){
    Cash.loadCashModel();
    Classifier.loadClassifierModel();
    super.initState();
  }

  @override
  void dispose() {
    myCameraController!.dispose();
    classifierInterpreter!.close();
    cashInterpreter!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: CashCamera()
    );
  }
}
