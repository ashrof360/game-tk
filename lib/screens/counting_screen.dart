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
    final itemLabel = item.name.toLowerCase();
    final itemLabelPlural = itemLabel.endsWith('s')
        ? itemLabel
        : '${itemLabel}s';

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
                      'How many $itemLabelPlural?',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        itemCount,
                        (index) => Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
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
