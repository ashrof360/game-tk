import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/category.dart';

class ShadowMatchingScreen extends StatefulWidget {
  const ShadowMatchingScreen({super.key});

  @override
  State<ShadowMatchingScreen> createState() => _ShadowMatchingScreenState();
}

class _ShadowMatchingScreenState extends State<ShadowMatchingScreen> {
  int currentItemIndex = 0;
  List<GameItem> shadowOptions = [];
  bool isCorrect = false;
  bool showDraggable = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (shadowOptions.isEmpty) {
      _prepareRound();
    }
  }

  void _prepareRound() {
    final provider = context.read<GameProvider>();
    final category = provider.selectedCategory;
    if (category != null && category.items.isNotEmpty) {
      final currentItem = category.items[currentItemIndex];
      shadowOptions = [currentItem];
      // Add 3 random other items
      final otherItems = category.items
          .where((item) => item != currentItem)
          .toList();
      otherItems.shuffle();
      shadowOptions.addAll(otherItems.take(3));
      shadowOptions.shuffle(); // Shuffle the order
    }
  }

  void _onCorrectMatch() {
    final provider = context.read<GameProvider>();
    provider.incrementScore();
    setState(() {
      isCorrect = true;
      showDraggable = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final category = provider.selectedCategory!;
      if (currentItemIndex < category.items.length - 1) {
        setState(() {
          currentItemIndex++;
          isCorrect = false;
          showDraggable = true;
        });
        _prepareRound();
      } else {
        provider.completeGame();
        Navigator.pop(context);
      }
    });
  }

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
        title: const Text('Shadow Matching'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pink],
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
                    if (showDraggable)
                      Draggable<GameItem>(
                        data: item,
                        feedback: Image.asset(
                          item.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        childWhenDragging: Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: Image.asset(
                          item.image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Drag the image to match the shadow!',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: shadowOptions.map((shadowItem) {
                  return DragTarget<GameItem>(
                    onAccept: (draggedItem) {
                      if (draggedItem == shadowItem) {
                        _onCorrectMatch();
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            shadowItem.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            if (isCorrect)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Correct! Well done!',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
