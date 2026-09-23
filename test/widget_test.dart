import 'package:ecocapital/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('carga la pantalla principal y los módulos', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(const EcoCapitalApp());
    await tester.pumpAndSettle();

    expect(find.text('EcoCapital'), findsWidgets);
    expect(find.text('Flujo de caja'), findsOneWidget);
    expect(find.text('Indicadores'), findsOneWidget);
    expect(find.text('Riesgo'), findsOneWidget);
    expect(find.text('Decisiones'), findsOneWidget);
    expect(find.text('Analista financiero'), findsOneWidget);
    expect(find.byKey(const ValueKey('module_cash_flow')), findsOneWidget);
    expect(find.byKey(const ValueKey('module_analyst')), findsOneWidget);
  });

  testWidgets('abre el módulo de flujo de caja', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(const EcoCapitalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module_cash_flow')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('button_calculate')), findsOneWidget);
    expect(find.byKey(const ValueKey('field_investment')), findsOneWidget);
  });

  testWidgets('abre el módulo de decisiones con sus casos', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(const EcoCapitalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module_decisions')));
    await tester.pumpAndSettle();

    expect(find.text('Panadería artesanal'), findsOneWidget);
  });
}
