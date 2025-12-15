import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/game_provider.dart';

class ListenPickScreen extends StatefulWidget {
  const ListenPickScreen({super.key});

  @override
  State<ListenPickScreen> createState() => _ListenPickScreenState();
}

class _ListenPickScreenState extends State<ListenPickScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  int currentItemIndex = 0;

  Future<void> _playPrompt(String assetPath, String fallbackText) async {
    // 1) Try playing a bundled asset audio file.
    try {
      await _audioPlayer.play(AssetSource(assetPath));
      return;
    } catch (_) {
      // ignore and try alternative path / fallback
    }

    // 2) Some setups use paths without the leading "assets/".
    if (assetPath.startsWith('assets/')) {
      try {
        await _audioPlayer.play(
          AssetSource(assetPath.substring('assets/'.length)),
        );
        return;
      } catch (_) {
        // ignore and fallback to TTS
      }
    }

    // 3) Fallback: speak the word using Text-to-Speech (works even if no audio assets exist).
    try {
      await _tts.stop();
      await _tts.speak(fallbackText);
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null || category.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('No items')));
    }

    final correctItem = category.items[currentItemIndex];
    final options = [
      correctItem,
      ...category.items.where((item) => item != correctItem).take(3),
    ]..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listen & Pick'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _playPrompt(correctItem.audio, correctItem.name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(20),
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        size: 50,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Listen and choose the correct item!',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 200,
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  return GestureDetector(
                    onTap: () {
                      if (item == correctItem) {
                        provider.incrementScore();
                        Future.delayed(const Duration(seconds: 1), () {
                          if (currentItemIndex < category.items.length - 1) {
                            setState(() {
                              currentItemIndex++;
                            });
                          } else {
                            provider.completeGame();
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Image.asset(item.image)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
