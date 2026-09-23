import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Gráfico animado: barras de flujo neto y línea de flujo acumulado.
class CashFlowChart extends StatelessWidget {
  const CashFlowChart({
    super.key,
    required this.netFlows,
    required this.cumulativeFlows,
  });

  final List<double> netFlows;
  final List<double> cumulativeFlows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = FinanceColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: TweenAnimationBuilder<double>(
                // Se reanima cada vez que cambian los datos.
                key:
                    ValueKey(Object.hashAll([...netFlows, ...cumulativeFlows])),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) {
                  return CustomPaint(
                    painter: _CashFlowPainter(
                      netFlows: netFlows,
                      cumulativeFlows: cumulativeFlows,
                      progress: progress,
                      positiveColor: finance.positive,
                      negativeColor: finance.negative,
                      lineColor: scheme.secondary,
                      axisColor: scheme.outlineVariant,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Legend(color: finance.positive, label: 'Flujo neto (+)'),
                _Legend(color: finance.negative, label: 'Flujo neto (−)'),
                _Legend(color: scheme.secondary, label: 'Flujo acumulado'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CashFlowPainter extends CustomPainter {
  _CashFlowPainter({
    required this.netFlows,
    required this.cumulativeFlows,
    required this.progress,
    required this.positiveColor,
    required this.negativeColor,
    required this.lineColor,
    required this.axisColor,
  });

  final List<double> netFlows;
  final List<double> cumulativeFlows;

  /// Avance de la animación de entrada (0 a 1).
  final double progress;
  final Color positiveColor;
  final Color negativeColor;
  final Color lineColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (netFlows.isEmpty) {
      return;
    }
    var maxAbs = 1.0;
    for (final value in [...netFlows, ...cumulativeFlows]) {
      maxAbs = math.max(maxAbs, value.abs());
    }
    final zeroY = size.height / 2;
    final scale = (size.height / 2 - 6) / maxAbs;
    final slot = size.width / netFlows.length;
    final barWidth = math.min(slot * 0.6, 36.0);
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    for (final fraction in [0.25, 0.75]) {
      final y = size.height * fraction;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        axisPaint..color = axisColor.withValues(alpha: 0.4),
      );
    }
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      axisPaint
        ..color = axisColor
        ..strokeWidth = 1.5,
    );
    for (var i = 0; i < netFlows.length; i++) {
      final value = netFlows[i] * progress;
      final left = slot * i + (slot - barWidth) / 2;
      final height = value.abs() * scale;
      final top = value >= 0 ? zeroY - height : zeroY;
      final base = netFlows[i] >= 0 ? positiveColor : negativeColor;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: value >= 0
              ? [base, base.withValues(alpha: 0.65)]
              : [base.withValues(alpha: 0.65), base],
        ).createShader(Rect.fromLTWH(left, top, barWidth, math.max(height, 1)));
      const radius = Radius.circular(6);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, height),
        topLeft: value >= 0 ? radius : Radius.zero,
        topRight: value >= 0 ? radius : Radius.zero,
        bottomLeft: value < 0 ? radius : Radius.zero,
        bottomRight: value < 0 ? radius : Radius.zero,
      );
      canvas.drawRRect(rect, paint);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = lineColor;
    final path = Path();
    final visible = (cumulativeFlows.length * progress).ceil();
    for (var i = 0; i < math.min(visible, cumulativeFlows.length); i++) {
      final x = slot * i + slot / 2;
      final y = zeroY - cumulativeFlows[i] * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _CashFlowPainter oldDelegate) {
    return oldDelegate.netFlows != netFlows ||
        oldDelegate.cumulativeFlows != cumulativeFlows ||
        oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor;
  }
}
