import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isTtsPlaying = false;
  DateTime _lastWrongPlay = DateTime.now().subtract(const Duration(seconds: 2));
  DateTime _lastTap = DateTime.now().subtract(const Duration(seconds: 2));

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
    await _tts.setPitch(1.85); // Dinaikkan mendekati titik melengking khas anak kecil
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
    await _tts.setPitch(1.6); // Dulu 1.2, dinaikkan agar "Try again" tetap terkesan seperti anak-anak
    await _tts.setSpeechRate(0.45);
    await _tts.speak("Try again!");
  }

  /// Plays a fast, high-pitch "Bop!" sound for UI taps
  Future<void> playTap() async {
    final now = DateTime.now();
    // Anti-spam for rapid tapping UI
    if (now.difference(_lastTap).inMilliseconds < 150) return;
    _lastTap = now;
    
    try {
      // AssetSource automatically prepends "assets/"
      await _sfxPlayer.play(AssetSource('audio/freesound_crunchpixstudio-clear-combo-7-394494.mp3'));
    } catch (e) {
      print("SFX error: $e");
    }
  }

  /// Plays background music in a loop
  Future<void> playBGM(String assetPath) async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("BGM error: $e");
    }
  }

  /// Stops background music
  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      print("Stop BGM error: $e");
    }
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
    await _tts.setPitch(1.85); // Pita suara dinaikkan ekstrem agar imut
    await _tts.setSpeechRate(0.45);
    await _tts.speak(fallbackText);
  }
}
