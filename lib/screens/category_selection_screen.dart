import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_data.dart';
import '../providers/game_provider.dart';
import 'game_selection_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Choose Category',
          style: TextStyle(
            color: Color(0xFF2E5A27),
            fontWeight: FontWeight.bold,
            fontSize: 28,
            shadows: [
              Shadow(color: Colors.white, offset: Offset(1, 1), blurRadius: 2),
            ],
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
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 25,
              childAspectRatio: 0.82,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              
              // Map category names to specific background colors/gradients
              final bgGradients = {
                'Fruits': [Colors.orange.shade400, Colors.red.shade600],
                'Stationery': [Colors.pink.shade300, Colors.pink.shade600],
                'Transportation': [Colors.lightBlue.shade300, Colors.deepPurple.shade600],
                'Animals': [Colors.yellow.shade400, Colors.orange.shade700],
                'Kitchen Utensils': [Colors.blue.shade400, Colors.blue.shade800],
              };

              final colors = bgGradients[category.name] ?? [Colors.grey, Colors.blueGrey];

              return GestureDetector(
                onTap: () {
                  context.read<GameProvider>().selectCategory(category);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameSelectionScreen(),
                    ),
                  );
                },
                child: Column(
                  children: [
                    // The Decorative Icon Frame
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Main Colorful Frame
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: const Color(0xFFFFD700), width: 4), // Golden border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset(
                                  category.icon,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 50, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          // Optional "Sparkles" could be added here as small icons
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Icon(Icons.star, color: Colors.white.withOpacity(0.4), size: 16),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 10,
                            child: Icon(Icons.star, color: Colors.white.withOpacity(0.4), size: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // The Wooden Banner for text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD2B48C), Color(0xFF8B4513)], // Tan to Brown
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFF5D4037), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723),
                          shadows: [
                            Shadow(color: Colors.white38, offset: Offset(1, 1), blurRadius: 1),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

