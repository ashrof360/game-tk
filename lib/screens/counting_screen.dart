import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  int currentItemIndex = 0;
  int itemCount = 3; 

  @override
  void initState() {
    super.initState();
    _resetItemCount();
  }

  void _resetItemCount() {
    final provider = context.read<GameProvider>();
    // Level-based item count range
    int minCount = 1 + (provider.currentLevel ~/ 3);
    int maxCount = 4 + provider.currentLevel;
    if (maxCount > 12) maxCount = 12; // Cap for Wrap layout
    if (minCount >= maxCount) minCount = maxCount - 1;

    setState(() {
      itemCount = minCount + (currentItemIndex * 7 + 3) % (maxCount - minCount + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null || category.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('No items')));
    }

    final item = category.items[currentItemIndex % category.items.length];
    final itemLabel = item.name.toLowerCase();
    final itemLabelPlural = itemLabel.endsWith('s')
        ? itemLabel
        : '${itemLabel}s';

    // Numbers for selection: current count + distractors
    int optionsCount = 3 + (provider.currentLevel ~/ 3);
    if (optionsCount > 6) optionsCount = 6;
    
    List<int> options = [itemCount];
    while(options.length < optionsCount) {
      int rand = 1 + (itemCount + options.length * 3 + 7) % 15;
      if (!options.contains(rand)) options.add(rand);
    }
    options.sort();

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
                      child: WoodenSign(title: 'Counting'),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 10),
              
              Text(
                'How many $itemLabelPlural?',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              
              const SizedBox(height: 10),

              // Items field
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(itemCount, (index) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(item.image, fit: BoxFit.contain),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Number Selection Panel
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 15,
                  children: options.map((num) {
                    return SizedBox(
                      width: 65,
                      height: 65,
                      child: GameBlock(
                        text: '$num',
                        baseColor: num % 2 == 0 ? Colors.orange : Colors.blue,
                        onTap: () {
                          if (num == itemCount) {
                            provider.incrementScore();
                            Future.delayed(const Duration(seconds: 1), () {
                              // Level-based rounds
                              int totalRounds = 2 + (provider.currentLevel ~/ 3);
                              if (totalRounds > category.items.length) totalRounds = category.items.length;

                              if (currentItemIndex < totalRounds - 1) {
                                setState(() {
                                  currentItemIndex++;
                                  _resetItemCount();
                                });
                              } else {
                                provider.completeLevel();
                                Navigator.pop(context);
                              }
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
