import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const LogoWidget({
    super.key,
    this.size = 120,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF6C63FF);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
                const Color(0xFF5A52D5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.4),
                blurRadius: size * 0.15,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: LogoPatternPainter(primaryColor),
                ),
              ),
              // Main logo icon
              Center(
                child: Icon(
                  Icons.chat_bubble,
                  size: size * 0.5,
                  color: Colors.white,
                ),
              ),
              // Network dots
              Positioned(
                top: size * 0.15,
                right: size * 0.15,
                child: Container(
                  width: size * 0.12,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(size * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: size * 0.03,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.15,
                left: size * 0.15,
                child: Container(
                  width: size * 0.08,
                  height: size * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Column(
            children: [
              Text(
                'MESSENGER',
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NI EDRICK',
                style: TextStyle(
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class LogoPatternPainter extends CustomPainter {
  final Color color;
  
  LogoPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw network pattern dots
    final dotSize = size.width * 0.03;
    final spacing = size.width * 0.15;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          dotSize / 2,
          paint,
        );
      }
    }

    // Draw connection lines
    final linePaint = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 1;

    // Diagonal lines
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmallLogoWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const SmallLogoWidget({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF6C63FF);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.chat_bubble,
              size: size * 0.5,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: size * 0.1,
            right: size * 0.1,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(size * 0.075),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
