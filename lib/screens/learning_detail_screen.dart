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

  bool _isSpelling = false;
  int _spellingIndex = -1;

  final Map<String, String> _translations = {
    'Apple': 'Apel', 'Bananas': 'Pisang', 'Orange': 'Jeruk', 'Grapes': 'Anggur',
    'Blueberry': 'Bluberi', 'Cherries': 'Ceri', 'Strawberry': 'Stroberi',
    'Pencil': 'Pensil', 'Book': 'Buku', 'Eraser': 'Penghapus', 'Ruler': 'Penggaris',
    'Car': 'Mobil', 'Bus': 'Bus', 'Truck': 'Truk', 'Bike': 'Sepeda',
    'Cat': 'Kucing', 'Dog': 'Anjing', 'Bird': 'Burung', 'Elephant': 'Gajah',
    'Plate': 'Piring', 'Mug': 'Cangkir', 'Fork': 'Garpu', 'Pot': 'Panci',
  };

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playSound();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    _pulseController.dispose();
    _isSpelling = false;
    super.dispose();
  }

  Future<void> _playSound() async {
    if (_isSpelling) return;
    final item = widget.category.items[_currentIndex];
    final assetPath = item.audio;
    final fallbackText = item.name;

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
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.6); 
      await _tts.setSpeechRate(0.45);
      await _tts.stop();
      await _tts.speak(fallbackText);
    } catch (_) {}
  }

  Future<void> _spellWord() async {
    if (_isSpelling) return;
    setState(() { _isSpelling = true; });
    final item = widget.category.items[_currentIndex];
    final letters = item.name.toUpperCase().split('');
    
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.8);
    await _tts.setSpeechRate(0.4);

    for (int i = 0; i < letters.length; i++) {
       if (!mounted || !_isSpelling) return;
       setState(() { _spellingIndex = i; });
       await _tts.speak(letters[i]);
       await Future.delayed(const Duration(milliseconds: 800));
    }
    
    if (!mounted) return;
    setState(() { 
      _spellingIndex = -1; 
      _isSpelling = false;
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    await _playSound();
  }

  void _nextItem() {
    if (_currentIndex < widget.category.items.length - 1) {
      _tts.stop();
      setState(() {
        _currentIndex++;
        _isSpelling = false;
        _spellingIndex = -1;
      });
      _playSound();
    }
  }

  void _previousItem() {
    if (_currentIndex > 0) {
      _tts.stop();
      setState(() {
        _currentIndex--;
        _isSpelling = false;
        _spellingIndex = -1;
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
    final translation = _translations[item.name] ?? '';
    final cardColor = Colors.white.withOpacity(0.95);
    final themeColor = Colors.green.shade600;
    final letters = item.name.toUpperCase().split('');

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
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
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
                     return ScaleTransition(
                       scale: animation,
                       child: RotationTransition(
                         turns: Tween<double>(begin: -0.05, end: 0.0).animate(animation),
                         child: child,
                       ),
                     );
                  },
                  child: ScaleTransition(
                    key: ValueKey<String>(item.name),
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
                              // Image with onTap
                              GestureDetector(
                                onTap: _playSound,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                  child: SizedBox(
                                    height: 160,
                                    child: Image.asset(
                                      item.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image, size: 100, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Translation Banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.orange.shade300, width: 2)
                                ),
                                child: Text(
                                  translation,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              
                              // Interactive Spelling Banner
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
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
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 4,
                                  runSpacing: 8,
                                  children: List.generate(letters.length, (idx) {
                                    bool isHighlighted = _spellingIndex == idx;
                                    return GestureDetector(
                                      onTap: () async {
                                        if(!_isSpelling) {
                                          await _tts.setLanguage("en-US");
                                          await _tts.speak(letters[idx]);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isHighlighted ? Colors.yellow.shade400 : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isHighlighted ? Border.all(color: Colors.white, width: 2) : null,
                                        ),
                                        child: Text(
                                          letters[idx],
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w900,
                                            color: isHighlighted ? Colors.red.shade700 : Colors.white,
                                            letterSpacing: 1,
                                            shadows: isHighlighted ? [] : const [
                                              Shadow(color: Colors.black38, offset: Offset(2, 2), blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          
                          // Audio Button
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
                          
                          // Spell Button (Magic Wand)
                          Positioned(
                            top: -20,
                            left: -20,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: const [
                                   BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
                                ]
                              ),
                              child: IconButton(
                                iconSize: 40,
                                icon: _isSpelling 
                                      ? const Icon(Icons.stop_rounded, color: Colors.white)
                                      : const Icon(Icons.auto_fix_high_rounded, color: Colors.white),
                                onPressed: () {
                                  if (_isSpelling) {
                                     _tts.stop();
                                     setState(() { _isSpelling = false; _spellingIndex = -1; });
                                  } else {
                                     _spellWord();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
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
