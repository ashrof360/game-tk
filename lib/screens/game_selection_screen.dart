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
      appBar: AppBar(
        title: Text('${category.name} Games'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen, Colors.yellow],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final isCompleted = provider.isGameCompleted(
              category.name,
              game['type'] as GameType,
            );

            return Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_fill,
                  color: isCompleted ? Colors.green : Colors.blue,
                  size: 40,
                ),
                title: Text(
                  game['name'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  provider.selectGameType(game['type'] as GameType);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => game['screen'] as Widget,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
