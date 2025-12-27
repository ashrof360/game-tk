import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'shadow_matching_screen.dart';
import 'spelling_tapping_screen.dart';
import 'listen_pick_screen.dart';
import 'counting_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null) {
      return const Scaffold(body: Center(child: Text('No category selected')));
    }

    final games = [
      {
        'name': 'Shadow Matching',
        'type': GameType.shadowMatching,
        'screen': const ShadowMatchingScreen(),
      },
      {
        'name': 'Spelling & Tapping',
        'type': GameType.spellingTapping,
        'screen': const SpellingTappingScreen(),
      },
      {
        'name': 'Listen & Pick',
        'type': GameType.listenPick,
        'screen': const ListenPickScreen(),
      },
      {
        'name': 'Counting',
        'type': GameType.counting,
        'screen': const CountingScreen(),
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/category_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Wood-style Title Banner (Code-based)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3E2723), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        '${category.name} Games',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Decorative Leaf (simulated)
                    Positioned(
                      left: -15,
                      top: -10,
                      child: Icon(Icons.eco, color: Colors.green.shade700, size: 40),
                    ),
                    Positioned(
                      right: -15,
                      bottom: -10,
                      child: Icon(Icons.eco, color: Colors.green.shade900, size: 40),
                    ),
                    // Back Button
                    Positioned(
                      left: -30,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF5D4037),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final isCompleted = provider.isGameCompleted(
                      category.name,
                      game['type'] as GameType,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            provider.selectGameType(game['type'] as GameType);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => game['screen'] as Widget,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            height: 85,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFF8D6E63), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                children: [
                                  // Left Icon (Circular Play)
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const RadialGradient(
                                        colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                                      ),
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Icon(
                                      isCompleted ? Icons.check_circle : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // Game Name
                                  Expanded(
                                    child: Text(
                                      game['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF4E342E),
                                      ),
                                    ),
                                  ),
                                  // Right Arrow
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFF8D6E63),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


