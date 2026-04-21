import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'category_selection_screen.dart';
import 'learning_english_screen.dart';
import '../services/sound_service.dart';

class MainSelectionScreen extends StatelessWidget {
  const MainSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final isIndo = provider.isIndonesian;
        
        return Scaffold(
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
              const SizedBox(height: 40),
              // Header Wooden Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFF3E2723), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  isIndo ? 'Pilih Mode' : 'Choose Mode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: 1.5,
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
              const Spacer(),
              // Selection Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildSelectionButton(
                      context,
                      title: isIndo ? 'Belajar' : 'Learn',
                      subtitle: isIndo ? 'Belajar Bahasa Inggris' : 'Learn English',
                      iconAsset: 'assets/images/learn_icon.png',
                      color1: const Color(0xFFFFB74D),
                      color2: const Color(0xFFF57C00),
                      onTap: () {
                        SoundService().playBGM('audio/sonican-joy-for-children-254840.mp3');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningEnglishScreen(),
                          ),
                        ).then((_) {
                           SoundService().playBGM('audio/hitslab-game-gaming-music-295075.mp3');
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildSelectionButton(
                      context,
                      title: isIndo ? 'Bermain' : 'Play',
                      subtitle: isIndo ? 'Main Game Seru' : 'Play Fun Games',
                      iconAsset: 'assets/images/play_icon.png',
                      color1: const Color(0xFF64B5F6),
                      color2: const Color(0xFF1976D2),
                      onTap: () {
                        SoundService().playBGM('audio/sonican-joy-for-children-254840.mp3');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategorySelectionScreen(),
                          ),
                        ).then((_) {
                           SoundService().playBGM('audio/hitslab-game-gaming-music-295075.mp3');
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Back Button
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5D4037),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildSelectionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconAsset,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 25),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconAsset,
                width: 65,
                height: 65,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                   const Icon(Icons.image, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
