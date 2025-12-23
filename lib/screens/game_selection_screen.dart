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
      appBar: AppBar(
        title: Text(
          '${category.name} Games',
          style: const TextStyle(
            color: Color(0xFF2E5A27), // Deep green color for text
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E5A27)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              final isCompleted = provider.isGameCompleted(
                category.name,
                game['type'] as GameType,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      provider.selectGameType(game['type'] as GameType);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => game['screen'] as Widget,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: Color(0xFF42A5F5), // Blue play button color
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCompleted ? Icons.check : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              game['name'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF333333),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
