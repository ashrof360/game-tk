import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

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
      appBar: AppBar(
        title: const Text('Spelling & Tapping'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
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
                    Container(
                      width: 150,
                      height: 150,
                      color: Colors.orange,
                      child: const Center(child: Text('Image')),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentSpelling,
                      style: const TextStyle(fontSize: 32, color: Colors.white),
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
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  return ElevatedButton(
                    onPressed: () {
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
                    },
                    child: Text(letter, style: const TextStyle(fontSize: 24)),
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
