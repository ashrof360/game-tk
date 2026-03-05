import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';

class LevelSelectionScreen extends StatelessWidget {
  final Widget gameScreen;

  const LevelSelectionScreen({super.key, required this.gameScreen});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;
    final gameType = provider.currentGameType;

    if (category == null || gameType == null) {
      return const Scaffold(body: Center(child: Text('Error: Missing category or game type')));
    }

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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 30),
                    ),
                    const Expanded(
                      child: Center(
                        child: WoodenSign(title: 'Pilih Level'),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(25),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isUnlocked = provider.isLevelUnlocked(category.name, gameType, level);
                    final isCompleted = provider.getHighestLevelCompleted(category.name, gameType) >= level;

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () {
                              provider.selectLevel(level);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => gameScreen),
                              );
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isUnlocked
                                ? [const Color(0xFFFFF3E0), const Color(0xFFFFCC80)]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFF8D6E63) : Colors.grey.shade700,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$level',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked ? const Color(0xFF4E342E) : Colors.white70,
                                  ),
                                ),
                                if (isCompleted)
                                  const Icon(Icons.star, color: Colors.orange, size: 20),
                              ],
                            ),
                            if (!isUnlocked)
                              const Icon(Icons.lock_rounded, color: Colors.white70, size: 40),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Text(
                  'Selesaikan level sebelumnya untuk membuka level selanjutnya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
