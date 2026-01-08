import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';

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
    try {
      await _audioPlayer.play(AssetSource(assetPath));
      return;
    } catch (_) {}

    if (assetPath.startsWith('assets/')) {
      try {
        await _audioPlayer.play(
          AssetSource(assetPath.substring('assets/'.length)),
        );
        return;
      } catch (_) {}
    }

    try {
      await _tts.stop();
      await _tts.speak(fallbackText);
    } catch (_) {}
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
      ...category.items.where((item) => item != correctItem).take(2), // Take 3 items total for better spacing
    ]..shuffle();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/game_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                  ),
                  const Expanded(
                    child: Center(
                      child: WoodenSign(title: 'Listen & Pick'),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              
              // Speaker Panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GamePanel(
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.brown.shade800,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orangeAccent, width: 4),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await _playPrompt(correctItem.audio, correctItem.name);
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 80, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _playPrompt(correctItem.audio, correctItem.name);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Listen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mascot Fox
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MascotAnchor(icon: Icons.pets, color: Colors.orange),
                ),
              ),
              
              const Spacer(),
              
              // Selection Row
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: options.map((item) {
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
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(item.image, fit: BoxFit.contain),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const Text(
                'Which one did you hear?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
