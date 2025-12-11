import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  int currentItemIndex = 0;
  int itemCount = 3; // Random count

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null || category.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('No items')));
    }

    final item = category.items[currentItemIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counting'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.orange],
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
                    Text(
                      'How many ${item.name.toLowerCase()}s?',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        itemCount,
                        (index) => Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.all(5),
                          color: Colors.white,
                          child: const Center(child: Text('Item')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final number = index + 1;
                  return ElevatedButton(
                    onPressed: () {
                      if (number == itemCount) {
                        provider.incrementScore();
                        Future.delayed(const Duration(seconds: 1), () {
                          if (currentItemIndex < category.items.length - 1) {
                            setState(() {
                              currentItemIndex++;
                              itemCount = (itemCount % 5) + 1; // Change count
                            });
                          } else {
                            provider.completeGame();
                            Navigator.pop(context);
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
