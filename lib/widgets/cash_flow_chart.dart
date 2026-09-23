import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Gráfico simple: barras de flujo neto y línea de flujo acumulado.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: _CashFlowPainter(
              netFlows: netFlows,
              cumulativeFlows: cumulativeFlows,
              positiveColor: Colors.green.shade600,
              negativeColor: scheme.error,
              lineColor: scheme.primary,
              axisColor: scheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _Legend(color: Colors.green.shade600, label: 'Flujo neto (+)'),
            _Legend(color: scheme.error, label: 'Flujo neto (−)'),
            _Legend(color: scheme.primary, label: 'Flujo acumulado'),
          ],
        ),
      ],
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
        Container(width: 12, height: 12, color: color),
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
    required this.positiveColor,
    required this.negativeColor,
    required this.lineColor,
    required this.axisColor,
  });

  final List<double> netFlows;
  final List<double> cumulativeFlows;
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
    final scale = (size.height / 2 - 4) / maxAbs;
    final slot = size.width / netFlows.length;
    final barWidth = slot * 0.6;
    final axisPaint = Paint();
    axisPaint.color = axisColor;
    axisPaint.strokeWidth = 1;
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), axisPaint);
    for (var i = 0; i < netFlows.length; i++) {
      final value = netFlows[i];
      final left = slot * i + (slot - barWidth) / 2;
      final top = value >= 0 ? zeroY - value * scale : zeroY;
      final height = value.abs() * scale;
      final barColor = value >= 0 ? positiveColor : negativeColor;
      final paint = Paint()..color = barColor;
      canvas.drawRect(Rect.fromLTWH(left, top, barWidth, height), paint);
    }
    final linePaint = Paint();
    linePaint.color = lineColor;
    linePaint.strokeWidth = 2.5;
    linePaint.style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = lineColor;
    final path = Path();
    for (var i = 0; i < cumulativeFlows.length; i++) {
      final x = slot * i + slot / 2;
      final y = zeroY - cumulativeFlows[i] * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _CashFlowPainter oldDelegate) {
    return oldDelegate.netFlows != netFlows ||
        oldDelegate.cumulativeFlows != cumulativeFlows ||
        oldDelegate.lineColor != lineColor;
  }
}
