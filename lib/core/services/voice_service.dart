import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
      "Barakalla!", 
      "Ofarin!", 
      "Siz juda aqllisiz!", 
      "Ajoyib!", 
      "Juda yaxshi!"
    ];
    praises.shuffle();
    await _tts.speak(praises.first);
  }

  static Future<void> speakError() async {
    List<String> encouraging = [
      "Yana bir bor urinib ko'r!", 
      "Xafa bo'lma, uddalaysan!", 
      "Deyarli topdingiz!", 
      "Harakat qiling!"
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
