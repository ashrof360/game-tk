import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/category.dart';
import '../widgets/game_components.dart';

class ShadowMatchingScreen extends StatefulWidget {
  const ShadowMatchingScreen({super.key});

  @override
  State<ShadowMatchingScreen> createState() => _ShadowMatchingScreenState();
}

class _ShadowMatchingScreenState extends State<ShadowMatchingScreen> {
  int currentItemIndex = 0;
  List<GameItem> shadowOptions = [];
  bool isCorrect = false;

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
      List<GameItem> options = [currentItem];
      
      final otherItems = category.items
          .where((item) => item != currentItem)
          .toList();
      otherItems.shuffle();
      options.addAll(otherItems.take(5)); // Take more to fill a 2x3 grid if possible
      options.shuffle();
      setState(() {
        shadowOptions = options;
      });
    }
  }

  void _onCorrectMatch() {
    final provider = context.read<GameProvider>();
    provider.incrementScore();
    setState(() {
      isCorrect = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final category = provider.selectedCategory!;
      if (currentItemIndex < category.items.length - 1) {
        setState(() {
          currentItemIndex++;
          isCorrect = false;
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

    final currentTarget = category.items[currentItemIndex];

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
                      child: WoodenSign(title: 'Shadow Matching'),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
              const SizedBox(height: 40),
              
              // Game Panel with Shadows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GamePanel(
                  height: 350,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: shadowOptions.length,
                    itemBuilder: (context, index) {
                      final item = shadowOptions[index];
                      return DragTarget<GameItem>(
                        onAccept: (draggedItem) {
                          if (draggedItem == item) {
                            _onCorrectMatch();
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          bool isMatched = isCorrect && item == currentTarget;
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isMatched ? Colors.green : Colors.brown.withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  isMatched ? Colors.transparent : Colors.black54,
                                  isMatched ? BlendMode.dst : BlendMode.srcIn,
                                ),
                                child: Image.asset(item.image, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Bottom area with the item to match
              if (!isCorrect)
                Draggable<GameItem>(
                  data: currentTarget,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Image.asset(currentTarget.image, width: 120, height: 120),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(currentTarget.image, width: 100, height: 100),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(currentTarget.image, width: 100, height: 100),
                  ),
                ),
                
              const SizedBox(height: 20),
              const Text(
                'Match the item to its shadow!',
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
