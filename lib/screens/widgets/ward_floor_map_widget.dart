// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 14: WardFloorMapWidget.build() -> Renders ward architectural floor map stack and legend.
// - Line 49: WardFloorMapWidget._legendItem() -> Builds legend dot indicator and label.
// - Line 70: _WardMapPainter.paint() -> Custom Canvas painter rendering rooms, corridors, nurse pin, and alert tags.
// ============================================================================

import 'package:flutter/material.dart';

class WardFloorMapWidget extends StatelessWidget {
  const WardFloorMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _WardMapPainter(),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(const Color(0xFFE11D48), 'Alert'),
                const SizedBox(width: 14),
                _legendItem(const Color(0xFF1E513B), 'Nurse'),
                const SizedBox(width: 14),
                _legendItem(const Color(0xFF0D9488), 'Pyxis'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _WardMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final corridorPaint = Paint()
      ..color = const Color(0xFFE8F5EE)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final corridorPath = Path();
    corridorPath.moveTo(w * 0.20, h * 0.40);
    corridorPath.lineTo(w * 0.50, h * 0.40);
    corridorPath.lineTo(w * 0.50, h * 0.72);
    corridorPath.lineTo(w * 0.80, h * 0.72);
    canvas.drawPath(corridorPath, corridorPaint);

    final roomBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final roomFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    void drawRoom(Rect rect, String title, {String? sub, Color? highlightBorder, Color? fillOverride}) {
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rrect, fillOverride != null ? (Paint()..color = fillOverride) : roomFillPaint);
      canvas.drawRRect(rrect, highlightBorder != null ? (Paint()..color = highlightBorder..strokeWidth = 1.8..style = PaintingStyle.stroke) : roomBorderPaint);

      final textSpan = TextSpan(
        text: title,
        style: const TextStyle(color: Color(0xFF334155), fontSize: 9, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width);
      textPainter.paint(canvas, Offset(rect.left + (rect.width - textPainter.width) / 2, rect.top + 6));

      if (sub != null) {
        final subSpan = TextSpan(
          text: sub,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 8),
        );
        final subPainter = TextPainter(
          text: subSpan,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: rect.width);
        subPainter.paint(canvas, Offset(rect.left + (rect.width - subPainter.width) / 2, rect.top + 18));
      }
    }

    drawRoom(Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.18, h * 0.22), 'RM 301', sub: 'Post-Op');
    drawRoom(Rect.fromLTWH(w * 0.28, h * 0.12, w * 0.18, h * 0.22), 'RM 302', sub: 'Cardiac');
    drawRoom(Rect.fromLTWH(w * 0.48, h * 0.10, w * 0.22, h * 0.25), 'NURSE STATION', sub: 'BAY A', fillOverride: const Color(0xFFF0FDF4), highlightBorder: const Color(0xFF1E513B));
    drawRoom(Rect.fromLTWH(w * 0.72, h * 0.12, w * 0.20, h * 0.22), 'RM 303', sub: 'Triage Bay');

    drawRoom(
      Rect.fromLTWH(w * 0.08, h * 0.54, w * 0.24, h * 0.32),
      'RM 304 (304-A)',
      sub: 'Ahmed Tariq',
      fillOverride: const Color(0xFFFFF1F2),
      highlightBorder: const Color(0xFFE11D48),
    );

    drawRoom(Rect.fromLTWH(w * 0.34, h * 0.58, w * 0.16, h * 0.26), 'PPE / Utility');
    drawRoom(
      Rect.fromLTWH(w * 0.52, h * 0.54, w * 0.22, h * 0.30),
      'Sat-Pharmacy',
      sub: 'Pyxis W3',
      fillOverride: const Color(0xFFF0FDFA),
      highlightBorder: const Color(0xFF0D9488),
    );
    drawRoom(Rect.fromLTWH(w * 0.76, h * 0.54, w * 0.18, h * 0.30), 'RM 306', sub: 'Isolation');

    final alertCenter = Offset(w * 0.13, h * 0.74);
    canvas.drawCircle(alertCenter, 10, Paint()..color = const Color(0xFFE11D48));
    final exclamationPainter = TextPainter(
      text: const TextSpan(text: '!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    exclamationPainter.paint(canvas, alertCenter - Offset(exclamationPainter.width / 2, exclamationPainter.height / 2));

    final nursePos = Offset(w * 0.44, h * 0.45);
    final nurseBgPaint = Paint()..color = const Color(0xFF1E513B);
    canvas.drawCircle(nursePos, 14, nurseBgPaint);
    final nurseIconPainter = TextPainter(
      text: const TextSpan(text: '👤', style: TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    nurseIconPainter.paint(canvas, nursePos - Offset(nurseIconPainter.width / 2, nurseIconPainter.height / 2));

    final nurseTagSpan = TextSpan(
      text: 'You (Fatima)',
      style: const TextStyle(color: Color(0xFF1E513B), fontSize: 8.5, fontWeight: FontWeight.bold),
    );
    final nurseTagPainter = TextPainter(text: nurseTagSpan, textDirection: TextDirection.ltr)..layout();
    nurseTagPainter.paint(canvas, Offset(nursePos.dx - nurseTagPainter.width / 2, nursePos.dy + 15));

    final pyxisPos = Offset(w * 0.63, h * 0.76);
    canvas.drawCircle(pyxisPos, 9, Paint()..color = const Color(0xFF0D9488));
    final pyxisIcon = TextPainter(
      text: const TextSpan(text: '💊', style: TextStyle(fontSize: 8)),
      textDirection: TextDirection.ltr,
    )..layout();
    pyxisIcon.paint(canvas, pyxisPos - Offset(pyxisIcon.width / 2, pyxisIcon.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
