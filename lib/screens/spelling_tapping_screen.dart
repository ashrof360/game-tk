import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';
import '../services/sound_service.dart';

class SpellingTappingScreen extends StatefulWidget {
  const SpellingTappingScreen({super.key});

  @override
  State<SpellingTappingScreen> createState() => _SpellingTappingScreenState();
}

class _SpellingTappingScreenState extends State<SpellingTappingScreen> {
  int currentItemIndex = 0;
  String currentSpelling = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playStartAudio();
    });
  }

  void _playStartAudio() {
    final provider = context.read<GameProvider>();
    final category = provider.selectedCategory;
    if (category != null && category.items.isNotEmpty) {
      final item = category.items[currentItemIndex % category.items.length];
      Future.delayed(const Duration(milliseconds: 300), () {
        final isIndo = context.read<GameProvider>().isIndonesian;
        SoundService().playQuestion(
          isIndo ? "Mari mengeja ${item.name}!" : "Let's spell ${item.name}!",
          isIndo: isIndo
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final isIndo = provider.isIndonesian;
        final category = provider.selectedCategory;

        if (category == null || category.items.isEmpty) {
          return Scaffold(body: Center(child: Text(isIndo ? 'Tidak ada buah' : 'No items')));
        }

    final item = category.items[currentItemIndex % category.items.length];
    final word = item.name.toUpperCase();
    final letters = word.split('');
    
    // Level-based distractors (extra letters)
    List<String> displayLetters = List.from(letters);
    int extraLettersCount = (provider.currentLevel - 1);
    if (extraLettersCount > 0) {
      final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
      alphabet.shuffle();
      displayLetters.addAll(alphabet.take(extraLettersCount));
    }
    displayLetters.shuffle();

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
                  Expanded(
                    child: Center(
                      child: WoodenSign(title: isIndo ? 'Mengeja Kata' : 'Spelling & Tapping'),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              
              // Item on "Stump"
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated Tree Stump
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 180,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B4513), Color(0xFF5D2E0A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
                            border: Border.all(color: const Color(0xFF3E2723), width: 2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Image.asset(
                          item.image,
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Mascot Owl
                      const Positioned(
                        right: -100,
                        top: 0,
                        child: MascotAnchor(icon: Icons.face_retouching_natural, color: Colors.brown),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Word Slots
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(word.length, (index) {
                    bool isFilled = index < currentSpelling.length;
                    return Container(
                      width: 40,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          isFilled ? currentSpelling[index] : '_',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Letter Selection Panel
              GamePanel(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.95,
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: displayLetters.map((letter) {
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: GameBlock(
                          text: letter,
                          onTap: () {
                            if (currentSpelling.length < word.length) {
                              // Check if the tapped letter matches the next letter in the word
                              String nextExpectedLetter = word[currentSpelling.length];
                              if (letter == nextExpectedLetter) {
                                // Right Letter
                                setState(() {
                                  currentSpelling += letter;
                                });
                                if (currentSpelling == word) {
                                  SoundService().playCorrect(isIndo: isIndo);
                                  provider.incrementScore();
                                  Future.delayed(const Duration(seconds: 1), () {
                                    // Level-based rounds
                                    int totalRounds = 1 + (provider.currentLevel ~/ 3);
                                    if (totalRounds > category.items.length) totalRounds = category.items.length;

                                    if (currentItemIndex < totalRounds - 1) {
                                      setState(() {
                                        currentItemIndex++;
                                        currentSpelling = '';
                                      });
                                      _playStartAudio();
                                    } else {
                                      provider.completeLevel();
                                      Navigator.pop(context);
                                    }
                                  });
                                }
                              } else {
                                // Wrong letter tapped
                                SoundService().playWrong(isIndo: isIndo);
                              }
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
