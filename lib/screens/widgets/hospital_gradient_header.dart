// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 29: MedicalCrossIcon.build() -> Renders embossed rounded medical cross badge.
// - Line 64: RoundedCrossPainter.paint() -> Draws geometrical rounded cross on Canvas.
// - Line 97: HmsLogo3D.build() -> Renders multilayer 3D 'HMS' typographic badge.
// - Line 169: IraqFlagWidget.build() -> Draws official national Iraqi flag symbol for phone prefix.
// ============================================================================

import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

typedef HospitalColors = AppColors;

class MedicalCrossIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color backgroundColor;
  final bool hasOutline;

  const MedicalCrossIcon({
    super.key,
    this.size = 72,
    this.color = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.hasOutline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: hasOutline
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: size * 0.04,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.65, size * 0.65),
        painter: RoundedCrossPainter(color: color),
      ),
    );
  }
}

class RoundedCrossPainter extends CustomPainter {
  final Color color;
  RoundedCrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double barWidth = w * 0.36;
    final double radius = barWidth * 0.45;

    final vRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: barWidth, height: h),
      Radius.circular(radius),
    );
    final hRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, h / 2), width: w, height: barWidth),
      Radius.circular(radius),
    );

    canvas.drawRRect(vRect, paint);
    canvas.drawRRect(hRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HmsLogo3D extends StatelessWidget {
  final double fontSize;

  const HmsLogo3D({super.key, this.fontSize = 58});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'HMS',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: const Color(0xFF133626).withValues(alpha: 0.4),
            shadows: [
              Shadow(
                color: const Color(0xFF0F2C1F).withValues(alpha: 0.5),
                offset: const Offset(0, 8),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 3.5),
          child: Text(
            'HMS',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: const Color(0xFFDED2C2),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 1.8),
          child: Text(
            'HMS',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: const Color(0xFFEDE4D7),
            ),
          ),
        ),
        Text(
          'HMS',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: const Color(0xFFFAF6EE),
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.8),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HmsLogoWidget extends StatelessWidget {
  final double size;
  const HmsLogoWidget({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/hms_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class IraqFlagWidget extends StatelessWidget {
  final double width;
  final double height;

  const IraqFlagWidget({super.key, this.width = 26, this.height = 17});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black.withValues(alpha: 0.2), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(child: Container(color: const Color(0xFFCE1126))),
          Expanded(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'الله أكبر',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF007A3D),
                    fontSize: 6,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: Container(color: const Color(0xFF000000))),
        ],
      ),
    );
  }
}
