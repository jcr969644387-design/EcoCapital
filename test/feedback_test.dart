import 'package:ecocapital/app.dart';
import 'package:ecocapital/services/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifica que el sonido y la vibración se disparan en las interacciones
/// reales de la aplicación, no solo desde los ajustes.
void main() {
  final calls = <MethodCall>[];

  List<String> sounds() => [
        for (final call in calls)
          if (call.method == 'playSound') (call.arguments as Map)['name'],
      ];

  int vibrations() => calls.where((c) => c.method == 'vibrate').length;

  setUp(() {
    calls.clear();
    final feedback = AppFeedback.instance;
    feedback.resetThrottle();
    feedback.soundEnabled.value = true;
    feedback.hapticsEnabled.value = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppFeedback.channel, (call) async {
      calls.add(call);
      if (call.method == 'getSettings') {
        return {'sound': true, 'haptics': true};
      }
      return true;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppFeedback.channel, null);
  });

  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EcoCapitalApp());
    await tester.pumpAndSettle();
    calls.clear();
  }

  testWidgets('abrir un módulo suena y vibra', (tester) async {
    await startApp(tester);

    await tester.tap(find.byKey(const ValueKey('module_indicators')));
    await tester.pumpAndSettle();

    expect(sounds(), contains('tap'));
    expect(vibrations(), greaterThan(0));
  });

  testWidgets('calcular el proyecto reproduce la simulación', (tester) async {
    await startApp(tester);
    await tester.tap(find.byKey(const ValueKey('module_cash_flow')));
    await tester.pumpAndSettle();
    calls.clear();

    await tester.ensureVisible(find.byKey(const ValueKey('button_calculate')));
    await tester.tap(find.byKey(const ValueKey('button_calculate')));
    await tester.pumpAndSettle();

    expect(sounds(), contains('simulate'));
    expect(vibrations(), greaterThan(0));
  });

  testWidgets('datos inválidos reproducen la señal de error', (tester) async {
    await startApp(tester);
    await tester.tap(find.byKey(const ValueKey('module_cash_flow')));
    await tester.pumpAndSettle();
    calls.clear();

    await tester.enterText(find.byKey(const ValueKey('field_years')), 'abc');
    await tester.ensureVisible(find.byKey(const ValueKey('button_calculate')));
    await tester.tap(find.byKey(const ValueKey('button_calculate')));
    await tester.pumpAndSettle();

    expect(sounds(), contains('error'));
  });

  testWidgets('responder un caso da retroalimentación sonora', (tester) async {
    await startApp(tester);
    await tester.tap(find.byKey(const ValueKey('module_decisions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Panadería artesanal'));
    await tester.pumpAndSettle();
    calls.clear();

    final option = find.byKey(const ValueKey('decision_invertir'));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('decision_feedback')), findsOneWidget);
    expect(
      sounds().where((s) => ['success', 'partial', 'error'].contains(s)),
      isNotEmpty,
    );
    expect(vibrations(), greaterThan(0));
  });

  testWidgets('desactivar el sonido mantiene solo la vibración',
      (tester) async {
    await startApp(tester);
    await tester.tap(find.byKey(const ValueKey('button_settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('switch_sound')));
    await tester.pumpAndSettle();
    expect(AppFeedback.instance.soundEnabled.value, isFalse);
    expect(calls.any((c) => c.method == 'setSettings'), isTrue);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    calls.clear();
    AppFeedback.instance.resetThrottle();

    await tester.tap(find.byKey(const ValueKey('module_risk')));
    await tester.pumpAndSettle();

    expect(sounds(), isEmpty);
    expect(vibrations(), greaterThan(0));
  });
}
