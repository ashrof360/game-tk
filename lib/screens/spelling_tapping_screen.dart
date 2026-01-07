import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';

class SpellingTappingScreen extends StatefulWidget {
  const SpellingTappingScreen({super.key});

  @override
  State<SpellingTappingScreen> createState() => _SpellingTappingScreenState();
}

class _SpellingTappingScreenState extends State<SpellingTappingScreen> {
  int currentItemIndex = 0;
  String currentSpelling = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null || category.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('No items')));
    }

    final item = category.items[currentItemIndex];
    final word = item.name.toUpperCase();
    final letters = word.split('');

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_new_bg.jpg'),
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
                      child: WoodenSign(title: 'Spelling & Tapping'),
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
                      width: 45,
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          isFilled ? currentSpelling[index] : '_',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Letter Selection Panel
              GamePanel(
                height: 180,
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: letters.map((letter) {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: GameBlock(
                          text: letter,
                          onTap: () {
                            if (currentSpelling.length < word.length) {
                              setState(() {
                                currentSpelling += letter;
                              });
                              if (currentSpelling == word) {
                                provider.incrementScore();
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (currentItemIndex < category.items.length - 1) {
                                    setState(() {
                                      currentItemIndex++;
                                      currentSpelling = '';
                                    });
                                  } else {
                                    provider.completeGame();
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
