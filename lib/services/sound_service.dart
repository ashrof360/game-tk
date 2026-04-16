import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isTtsPlaying = false;
  DateTime _lastWrongPlay = DateTime.now().subtract(const Duration(seconds: 2));

  SoundService._internal() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    
    _tts.setStartHandler(() {
      _isTtsPlaying = true;
    });
    
    _tts.setCompletionHandler(() {
      _isTtsPlaying = false;
    });
    
    _tts.setCancelHandler(() {
      _isTtsPlaying = false;
    });
  }

  /// Plays a general TTS question or phrase
  Future<void> playQuestion(String text) async {
    await _tts.stop();
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.6);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }

  /// Synthesizes an extra high-pitch cheerful "Correct!"
  Future<void> playCorrect() async {
    await _tts.stop();
    await _tts.setLanguage("en-US");
    await _tts.setPitch(2.0); // Maximum pitch for cheerful "Ding" response
    await _tts.setSpeechRate(0.5);
    await _tts.speak("Correct!");
  }

  /// Synthesizes a slightly slower, lower pitch "Try again!" with anti-spam
  Future<void> playWrong() async {
    final now = DateTime.now();
    // Anti-spam to prevent overlapping "Try again!" voices if user taps rapidly
    if (now.difference(_lastWrongPlay).inMilliseconds < 1200) return;
    
    _lastWrongPlay = now;
    
    // Stop current speaking just in case so it plays immediately
    if (_isTtsPlaying) await _tts.stop(); 
    
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.2); 
    await _tts.setSpeechRate(0.45);
    await _tts.speak("Try again!");
  }

  /// Plays item audio based on game data (local mp3 asset, or fallback TTS)
  Future<void> playItemAudio(String assetPath, String fallbackText) async {
    await _tts.stop();
    
    try {
      await _audioPlayer.play(AssetSource(assetPath));
      return;
    } catch (_) {}

    if (assetPath.startsWith('assets/')) {
      try {
        await _audioPlayer.play(AssetSource(assetPath.substring('assets/'.length)));
        return;
      } catch (_) {}
    }

    // Fallback to TTS if no audio file present
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.6);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(fallbackText);
  }
}
