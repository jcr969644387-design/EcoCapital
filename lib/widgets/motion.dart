import 'package:flutter/material.dart';

import '../services/app_feedback.dart';

/// Aparición suave (desvanecido + desplazamiento) con retardo escalonado.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 24,
  });

  final Widget child;

  /// Posición en la lista; cada elemento aparece un poco después.
  final int index;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.08).clamp(0.0, 0.5);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index * 60).clamp(0, 360)),
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offset),
            child: child,
          ),
        );
      },
    );
  }
}

/// Superficie que se hunde levemente al presionarla y da respuesta
/// sonora/háptica.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.cue = FeedbackCue.tap,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final FeedbackCue cue;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onHighlightChanged: _setPressed,
          onTap: onTap == null
              ? null
              : () {
                  AppFeedback.instance.play(widget.cue);
                  onTap();
                },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Texto que se anima al cambiar de valor (útil para cifras).
class AnimatedValueText extends StatelessWidget {
  const AnimatedValueText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (current, previous) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, if (current != null) current],
        );
      },
      child: Text(text, key: ValueKey(text), style: style),
    );
  }
}

/// Abre una pantalla con sonido y vibración de pulsación.
void openScreen(BuildContext context, Widget screen) {
  AppFeedback.instance.tap();
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
