import 'package:flutter/material.dart';
import 'dart:math';

class InteractiveFeedback {
  /// Munculkan efek bintang meledak meriah (Berhasil)
  static void showSuccess(BuildContext context, {required VoidCallback onComplete}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, 
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return const _SuccessOverlay();
      },
    );
    // Durasi tayang sukses
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      onComplete();
    });
  }

  /// Munculkan animasi muka goyang/sedih (Salah)
  static void showFail(BuildContext context, {required VoidCallback onComplete}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, anim1, anim2) {
        return const _FailOverlay();
      },
    );
    // Durasi tayang gagal lebih singkat
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (context.mounted) {
         Navigator.of(context, rootNavigator: true).pop();
      }
      onComplete();
    });
  }
}

// ============================================
// ANIMASI SUKSES (Bintang Meledak)
// ============================================
class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay();

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random rand = Random();
  late List<_BurstParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    // Buat 40 partikel bintang
    _particles = List.generate(40, (index) => _BurstParticle(rand));
    _controller.addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cx = constraints.maxWidth / 2;
            double cy = constraints.maxHeight / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: _particles.map((p) {
                double progress = Curves.easeOutCubic.transform(_controller.value);
                
                // Radius burst
                double r = progress * p.distance;
                double x = cx + cos(p.angle) * r;
                double y = cy + sin(p.angle) * r;
                
                // Jatuh dikit karena gravitasi (di ujung animasi)
                y += Curves.easeIn.transform(_controller.value) * 100;

                // Opacity fadeout di dekat akhir
                double opacity = 1.0;
                if (_controller.value > 0.8) {
                   opacity = (1.0 - _controller.value) * 5.0;
                }

                return Positioned(
                  left: x - p.size / 2,
                  top: y - p.size / 2,
                  child: Transform.rotate(
                    angle: progress * p.spinSpeed,
                    child: Transform.scale(
                      scale: _controller.value < 0.2 ? (_controller.value * 5) : 1.0, // Pop effect
                      child: Icon(
                        Icons.star,
                        color: p.color.withOpacity(opacity.clamp(0.0, 1.0)),
                        size: p.size,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }
        ),
      ),
    );
  }
}

class _BurstParticle {
  late double angle;
  late double distance;
  late double spinSpeed;
  late double size;
  late Color color;

  _BurstParticle(Random r) {
    angle = r.nextDouble() * 2 * pi; // Arah ledakan 360 derajat
    distance = r.nextDouble() * 250 + 100; // Jauh ledakan 100 - 350 pixel
    spinSpeed = (r.nextDouble() - 0.5) * 20;
    size = r.nextDouble() * 25 + 15;
    color = const [Colors.amber, Colors.yellow, Colors.orange, Colors.white, Colors.pinkAccent, Colors.lightBlueAccent][r.nextInt(6)];
  }
}

// ============================================
// ANIMASI GAGAL (Muka Sedih Goyang)
// ============================================
class _FailOverlay extends StatefulWidget {
  const _FailOverlay();

  @override
  State<_FailOverlay> createState() => _FailOverlayState();
}

class _FailOverlayState extends State<_FailOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Efek Wobble (getar ke kiri kanan)
            double shake = sin(_controller.value * pi * 5) * 15; // 5 getaran
            // Menghilang di ujung
            double opacity = 1.0;
            if (_controller.value > 0.8) {
               opacity = (1.0 - _controller.value) * 5.0;
            }

            return Center(
              child: Transform.translate(
                offset: Offset(shake, 0),
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                      ]
                    ),
                    child: const Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      color: Colors.redAccent,
                      size: 80,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
