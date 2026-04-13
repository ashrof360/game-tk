import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_components.dart';
import 'shadow_matching_screen.dart';
import 'spelling_tapping_screen.dart';
import 'listen_pick_screen.dart';
import 'counting_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom (Level 1) initially
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _getGameScreenForLevel(int level) {
    int mod = level % 4;
    switch (mod) {
      case 1: return const CountingScreen();
      case 2: return const ShadowMatchingScreen();
      case 3: return const ListenPickScreen();
      case 0:
      default: return const SpellingTappingScreen();
    }
  }

  String _getGameNameForLevel(int level) {
    int mod = level % 4;
    switch (mod) {
      case 1: return 'Counting';
      case 2: return 'Shadows';
      case 3: return 'Listen';
      case 0:
      default: return 'Spelling';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final category = provider.selectedCategory;

    if (category == null) {
      return const Scaffold(body: Center(child: Text('Error: Missing category')));
    }

    final int totalLevels = 10;
    final double levelHeight = 160.0;
    final double totalHeight = totalLevels * levelHeight + 200.0; // Extra padding
    final double screenWidth = MediaQuery.of(context).size.width;

    // Generate node positions (Bottom to Top)
    List<Offset> nodePositions = [];
    for (int i = 0; i < totalLevels; i++) {
        // i=0 is Level 1. It should be at the bottom.
        double y = totalHeight - 150.0 - (i * levelHeight);
        // Alternate left and right with sine wave
        double x = screenWidth / 2 + sin(i * 1.5) * (screenWidth * 0.25);
        nodePositions.add(Offset(x, y));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Level Map',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            shadows: [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
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
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: totalHeight,
            width: screenWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Draw the winding path first
                Positioned.fill(
                  child: CustomPaint(
                    painter: PathPainter(positions: nodePositions),
                  ),
                ),
                
                // Draw nodes
                ...List.generate(totalLevels, (index) {
                  final level = index + 1;
                  final position = nodePositions[index];
                  final isUnlocked = provider.isLevelUnlocked(category.name, level);
                  final isCompleted = provider.getHighestLevelCompleted(category.name) >= level;
                  
                  // For the mascot, use category items if available
                  final iconAsset = category.items[level % category.items.length].image;

                  return Positioned(
                    left: position.dx - 75, // Center the 150px wide node
                    top: position.dy - 75,
                    child: _buildNode(
                      context, 
                      level, 
                      isUnlocked, 
                      isCompleted, 
                      iconAsset, 
                      provider, 
                      category.name
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context, 
    int level, 
    bool isUnlocked, 
    bool isCompleted, 
    String iconAsset,
    GameProvider provider,
    String categoryName
  ) {
    // Colors based on level type
    final isBlue = level % 2 != 0;
    final primaryColor = isUnlocked ? (isBlue ? const Color(0xFF1976D2) : const Color(0xFF7B1FA2)) : Colors.grey.shade600;
    final lightColor = isUnlocked ? (isBlue ? const Color(0xFF64B5F6) : const Color(0xFFBA68C8)) : Colors.grey.shade400;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              provider.selectLevel(level);
              provider.selectGameType(GameType.mixed); 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _getGameScreenForLevel(level),
                ),
              ).then((_) {
                 // Refresh state when coming back
                 setState((){});
              });
            }
          : null,
      child: SizedBox(
        width: 150,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Base (Wooden/Stone)
            Positioned(
              bottom: 45,
              child: Container(
                width: 110,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63),
                  borderRadius: BorderRadius.all(Radius.elliptical(110, 40)),
                  border: Border.all(color: const Color(0xFF4E342E), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, offset: Offset(0, 5), blurRadius: 4),
                  ]
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA1887F),
                      borderRadius: BorderRadius.all(Radius.elliptical(90, 25)),
                    ),
                  ),
                ),
              ),
            ),
            
            // Item / Lock
            Positioned(
              bottom: 60,
              child: isUnlocked
                  ? Image.asset(iconAsset, width: 75, height: 75, fit: BoxFit.contain)
                  : const Icon(Icons.lock, color: Colors.amber, size: 70, shadows: [
                       Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)
                    ]),
            ),
            
            // Pill Label
            Positioned(
              bottom: 15,
              child: Container(
                padding: const EdgeInsets.only(right: 12),
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [lightColor, primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 4),
                  ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circle Number
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '$level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _getGameNameForLevel(level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        shadows: [Shadow(color: Colors.black45, offset: Offset(1, 1), blurRadius: 2)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Stars (if completed)
            if (isCompleted)
              Positioned(
                bottom: -5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 22, shadows: [Shadow(color: Colors.black54, blurRadius: 2)]),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Icon(Icons.star, color: Colors.amber, size: 26, shadows: [Shadow(color: Colors.black54, blurRadius: 2)]),
                    ),
                    Icon(Icons.star, color: Colors.amber, size: 22, shadows: [Shadow(color: Colors.black54, blurRadius: 2)]),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> positions;

  PathPainter({required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    Paint borderPaint = Paint()
      ..color = const Color(0xFFD35400) // Deep orange border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint pathPaint = Paint()
      ..color = const Color(0xFFF1C40F) // Yellow/gold path inside
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint dashPaint = Paint()
      ..color = const Color(0xFFE67E22) // Inner dashed line equivalent 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    path.moveTo(positions.first.dx, positions.first.dy);

    for (int i = 0; i < positions.length - 1; i++) {
       Offset p0 = positions[i];
       Offset p1 = positions[i + 1];
       // Create a control point for a quadratic curve
       // For a snake path, we can put the control point further out in X
       double midX = (p0.dx + p1.dx) / 2;
       // Add some bulging to make it snake properly:
       double ctrlX = (p0.dx < p1.dx) ? p0.dx - 60 : p0.dx + 60;
       if(i == 0) ctrlX = p1.dx; // smooth start
       double ctrlY = (p0.dy + p1.dy) / 2;
       path.quadraticBezierTo(ctrlX, ctrlY, p1.dx, p1.dy);
    }

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, pathPaint);
    
    // Optional: Draw simple line segments inside the path to mimic stone pieces?
    // Using simple PathMetrics can do dashes, but a simple line is fine for now
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return true; // Simple repaint
  }
}
