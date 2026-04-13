import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/category.dart';
import '../widgets/game_components.dart';

class LearningDetailScreen extends StatefulWidget {
  final Category category;

  const LearningDetailScreen({super.key, required this.category});

  @override
  State<LearningDetailScreen> createState() => _LearningDetailScreenState();
}

class _LearningDetailScreenState extends State<LearningDetailScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 300),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );

    // Auto-play the first word
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    final item = widget.category.items[_currentIndex];
    final assetPath = item.audio;
    final fallbackText = item.name;

    // Trigger visual pulse
    _pulseController.forward().then((_) => _pulseController.reverse());

    try {
      await _audioPlayer.play(AssetSource(assetPath));
      return;
    } catch (_) {}

    if (assetPath.startsWith('assets/')) {
      try {
        await _audioPlayer.play(
          AssetSource(assetPath.substring('assets/'.length)),
        );
        return;
      } catch (_) {}
    }

    try {
      await _tts.setPitch(1.2); // Child-friendly slightly higher pitch
      await _tts.setSpeechRate(0.5); // Slightly slower for clarity
      await _tts.stop();
      await _tts.speak(fallbackText);
    } catch (_) {}
  }

  void _nextItem() {
    if (_currentIndex < widget.category.items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playSound();
    }
  }

  void _previousItem() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _playSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.items.isEmpty) {
       return const Scaffold(body: Center(child: Text('No items to learn.')));
    }

    final item = widget.category.items[_currentIndex];

    // Colors matching a fun vibe
    final cardColor = Colors.white.withOpacity(0.95);
    final themeColor = Colors.green.shade600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            shadows: [
              Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 4),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
            child: const Icon(Icons.arrow_back, color: Colors.white)
          ),
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
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // Animated Progress Tracker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor, width: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${_currentIndex + 1} / ${widget.category.items.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              
              // Interactive Flashcard Center
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                     // Dynamic scale and rotate transition
                     return ScaleTransition(
                       scale: animation,
                       child: RotationTransition(
                         turns: Tween<double>(begin: -0.05, end: 0.0).animate(animation),
                         child: child,
                       ),
                     );
                  },
                  // Use item.name as key so it triggers transition when item changes
                  child: GestureDetector(
                    key: ValueKey<String>(item.name),
                    onTap: _playSound,
                    child: ScaleTransition( // Added nested scale for pulse effect on audio playing
                      scale: _pulseAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.amber.shade700, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 40),
                                // Image with bouncy feel
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: SizedBox(
                                    height: 180,
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image, size: 100, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                // Text Banner Segment
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 25),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                       colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                                       begin: Alignment.topCenter,
                                       end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(34),
                                      bottomRight: Radius.circular(34),
                                    ),
                                  ),
                                  child: Text(
                                    item.name.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Audio Button Badge
                            Positioned(
                              top: -20,
                              right: -20,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: const [
                                     BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
                                  ]
                                ),
                                child: IconButton(
                                  iconSize: 40,
                                  icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                                  onPressed: _playSound,
                                ),
                              ),
                            ),
                            
                            // Mascot Mascot (Owl/Bird) looking at the card
                            const Positioned(
                              top: -40,
                              left: -10,
                              child: MascotAnchor(icon: Icons.face_retouching_natural, color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              
              // Fun Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: _currentIndex > 0 ? _previousItem : null,
                      enabled: _currentIndex > 0,
                      color: Colors.pink.shade400,
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward_rounded,
                      onTap: _currentIndex < widget.category.items.length - 1 ? _nextItem : null,
                      enabled: _currentIndex < widget.category.items.length - 1,
                      color: Colors.green.shade500,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
     required IconData icon, 
     required VoidCallback? onTap, 
     required bool enabled, 
     required Color color
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
             colors: enabled 
                ? [color.withOpacity(0.7), color] 
                : [Colors.grey.shade400, Colors.grey.shade500],
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: enabled
              ? [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 5))]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}
