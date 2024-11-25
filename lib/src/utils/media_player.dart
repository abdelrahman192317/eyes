import 'package:flutter_tts/flutter_tts.dart';

String audioFile = "assets/cash_recognition/audio/";

class MediaPlayer {

  static final FlutterTts flutterTts = FlutterTts();

  static Future speak(String text) async {
    await stop();
    await flutterTts.speak(text);
  }

  static Future stop() async => await flutterTts.stop();
}
