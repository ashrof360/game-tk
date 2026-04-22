import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/interactive_feedback.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';
import '../services/sound_service.dart';

class ListenPickScreen extends StatefulWidget {
  const ListenPickScreen({super.key});

  @override
  State<ListenPickScreen> createState() => _ListenPickScreenState();
}

class _ListenPickScreenState extends State<ListenPickScreen> {
  int currentItemIndex = 0;

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
      final correctItem = category.items[currentItemIndex % category.items.length];
      Future.delayed(const Duration(milliseconds: 300), () {
        SoundService().playItemAudio(correctItem.audio, correctItem.name);
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

    final correctItem = category.items[currentItemIndex % category.items.length];
    
    // Level-based distractors
    int optionsCount = 2 + (provider.currentLevel ~/ 3);
    if (optionsCount > 6) optionsCount = 6;
    if (optionsCount > category.items.length) optionsCount = category.items.length;

    final otherItems = category.items.where((item) => item != correctItem).toList();
    otherItems.shuffle();
    
    final options = [
      correctItem,
      ...otherItems.take(optionsCount - 1),
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
                  Expanded(
                    child: Center(
                      child: WoodenSign(title: isIndo ? 'Dengar & Pilih' : 'Listen & Pick'),
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
                            await SoundService().playItemAudio(correctItem.audio, correctItem.name);
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 80, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isIndo ? 'Ketuk untuk Mendengar' : 'Tap to Listen',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Spacer(),
              
              // Selection Wrap instead of Row for many options
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                  children: options.map((item) {
                    return GestureDetector(
                      onTap: () {
                        if (item == correctItem) {
                          SoundService().playCorrect(isIndo: isIndo);
                          InteractiveFeedback.showSuccess(context, onComplete: () {
                            provider.incrementScore();
                            // Level-based rounds
                            int totalRounds = 2 + (provider.currentLevel ~/ 2);
                            if (totalRounds > category.items.length) totalRounds = category.items.length;

                            if (currentItemIndex < totalRounds - 1) {
                              setState(() {
                                currentItemIndex++;
                              });
                              _playStartAudio();
                            } else {
                              provider.completeLevel();
                              Navigator.pop(context);
                            }
                          });
                        } else {
                          SoundService().playWrong(isIndo: isIndo);
                          InteractiveFeedback.showFail(context, onComplete: () {});
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
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
              
              Text(
                isIndo ? 'Mana yang kamu dengar?' : 'Which one did you hear?',
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
