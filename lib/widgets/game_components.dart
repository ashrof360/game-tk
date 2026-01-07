import 'package:flutter/material.dart';

class WoodenSign extends StatelessWidget {
  final String title;
  final double fontSize;

  const WoodenSign({
    super.key,
    required this.title,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // The main sign
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD2B48C), Color(0xFF8B4513)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF5D2E0A), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5D2E0A),
              shadows: const [
                Shadow(
                  color: Colors.white70,
                  offset: Offset(1, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ),
        // Ropes (simulated)
        Positioned(
          top: -15,
          left: 30,
          child: Container(
            width: 4,
            height: 20,
            color: const Color(0xFF5D2E0A),
          ),
        ),
        Positioned(
          top: -15,
          right: 30,
          child: Container(
            width: 4,
            height: 20,
            color: const Color(0xFF5D2E0A),
          ),
        ),
      ],
    );
  }
}

class GamePanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GamePanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5DEB3).withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B4513), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GameBlock extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color baseColor;
  final bool isSelected;

  const GameBlock({
    super.key,
    required this.text,
    required this.onTap,
    this.baseColor = const Color(0xFFF4A460),
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.shade700 : baseColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B4513), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 3),
              blurRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MascotAnchor extends StatelessWidget {
  final IconData icon;
  final Color color;

  const MascotAnchor({
    super.key,
    required this.icon,
    this.color = Colors.brown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 60, color: color),
    );
  }
}
