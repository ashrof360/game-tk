import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/category.dart';
import '../widgets/game_components.dart';
import '../services/sound_service.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
         final isIndo = context.read<GameProvider>().isIndonesian;
         SoundService().playQuestion(
           isIndo ? "Cocokkan benda dengan bayangannya!" : "Match the item to its shadow!",
           isIndo: isIndo
         );
      });
    });
  }

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
      final currentItem = category.items[currentItemIndex % category.items.length];
      List<GameItem> options = [currentItem];
      
      final otherItems = category.items
          .where((item) => item != currentItem)
          .toList();
      otherItems.shuffle();
      
      // Level-based distractors
      int distractorCount = 2 + (provider.currentLevel ~/ 3);
      if (distractorCount > 5) distractorCount = 5; // Max grid size constraints
      if (distractorCount > otherItems.length) distractorCount = otherItems.length;

      options.addAll(otherItems.take(distractorCount));
      options.shuffle();
      setState(() {
        shadowOptions = options;
      });
    }
  }

  void _onCorrectMatch(bool isIndo) {
    final provider = context.read<GameProvider>();
    provider.incrementScore();
    setState(() {
      isCorrect = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      final category = provider.selectedCategory!;
      // Level-based rounds
      int totalRounds = 2 + (provider.currentLevel ~/ 2);
      if (totalRounds > category.items.length) totalRounds = category.items.length;

      if (currentItemIndex < totalRounds - 1) {
        setState(() {
          currentItemIndex++;
          isCorrect = false;
        });
        _prepareRound();
      } else {
        provider.completeLevel();
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final isIndo = provider.isIndonesian;
        final category = provider.selectedCategory;

        if (category == null || category.items.isEmpty) {
          return Scaffold(body: Center(child: Text(isIndo ? 'Tidak ada item' : 'No items')));
        }

        final currentTarget = category.items[currentItemIndex];

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
                      child: WoodenSign(title: isIndo ? 'Cari Bayangan' : 'Shadow Matching'),
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
                            if (item == currentTarget) {
                              SoundService().playCorrect(isIndo: isIndo);
                              _onCorrectMatch(isIndo);
                            } else {
                              SoundService().playWrong(isIndo: isIndo);
                            }
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
                  onDraggableCanceled: (velocity, offset) {
                     SoundService().playWrong(isIndo: isIndo);
                  },
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
              Text(
                isIndo ? 'Cocokkan benda dengan bayangannya!' : 'Match the item to its shadow!',
                style: const TextStyle(
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
      },
    );
  }
}
