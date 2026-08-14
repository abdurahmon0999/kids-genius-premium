import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:easy_localization/easy_localization.dart';

class VoiceService {
  static final FlutterTts _tts = FlutterTts();
  static final SpeechToText _stt = SpeechToText();

  static Future<void> init() async {
    // Try to set Kazakh (very similar to Uzbek), fallback to Turkish
    try {
      bool isKazakhAvailable = await _tts.isLanguageAvailable("kk-KZ");
      if (isKazakhAvailable) {
        await _tts.setLanguage("kk-KZ");
      } else {
        bool isUzbekAvailable = await _tts.isLanguageAvailable("uz-UZ");
        if (isUzbekAvailable) {
          await _tts.setLanguage("uz-UZ");
        } else {
          await _tts.setLanguage("tr-TR");
        }
      }
    } catch (e) {
      await _tts.setLanguage("tr-TR");
    }
    
    await _tts.setSpeechRate(0.4); // Slower for better clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.9); // Deeper, more natural voice
  }

  static Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  static Future<void> speakSuccess() async {
    List<String> praises = [
      "praise_1".tr(), 
      "praise_2".tr(), 
      "praise_3".tr(), 
      "praise_4".tr(), 
      "praise_5".tr()
    ];
    praises.shuffle();
    await _tts.speak(praises.first);
  }

  static Future<void> speakError() async {
    List<String> encouraging = [
      "encourage_1".tr(), 
      "encourage_2".tr(), 
      "encourage_3".tr(), 
      "encourage_4".tr()
    ];
    encouraging.shuffle();
    await _tts.speak(encouraging.first);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static Future<void> listen(Function(String) onResult) async {
    bool available = await _stt.initialize();
    if (available) {
      _stt.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    }
  }

  static void stopListening() {
    _stt.stop();
  }
}
