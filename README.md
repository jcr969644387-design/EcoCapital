# EcoCapital

Aplicación móvil educativa para aprender **evaluación de inversiones**, riesgo y rentabilidad mediante simulaciones con **proyectos ficticios**.

> ⚠️ **Advertencia educativa y financiera.** EcoCapital es una herramienta exclusivamente educativa. Usa escenarios ficticios y cálculos simplificados. **No constituye asesoramiento financiero ni recomendación de inversión real.** No usa datos personales, cuentas bancarias, conexión con bolsas de valores ni operaciones reales de compra o venta.

---

## Descripción

Los estudiantes suelen conocer las fórmulas del VAN y la TIR, pero tienen poca práctica construyendo flujos de caja, comparando escenarios y decidiendo bajo incertidumbre. EcoCapital convierte esas fórmulas en un **laboratorio de decisiones**: el estudiante modifica un proyecto y observa, en el momento, cómo cambian los indicadores y por qué.

## Objetivo

Enseñar evaluación básica de inversiones mediante escenarios financieros ficticios, con práctica activa, retroalimentación inmediata y explicaciones en lenguaje sencillo.

## Usuarios

- Estudiantes de **Economía** (cursos de evaluación de proyectos, finanzas corporativas).
- Estudiantes de **Administración** y **Finanzas**.
- Programas de **educación financiera**.

## Módulos

| Módulo | Qué hace el estudiante | Qué aprende |
|---|---|---|
| **1. Flujo de caja** | Ingresa inversión, ingresos, costos, vida, tasa, crecimiento, escenario y riesgo | Construir flujo neto, acumulado y descontado |
| **2. Indicadores** | Revisa VAN, TIR, retorno acumulado, recuperación simple y descontada, margen; mueve la tasa con un control deslizante | Interpretar cada indicador y su sensibilidad a la tasa |
| **3. Riesgo** | Cambia el nivel de riesgo y compara escenarios pesimista, base y optimista | Cómo el riesgo reduce el VAN y amplía la incertidumbre |
| **4. Decisiones** | Resuelve 6 casos ficticios: invertir, no invertir o revisar | Tomar decisiones justificadas con indicadores y escenarios |
| **5. Analista financiero local** | Pregunta al analista por VAN, tasa, TIR, riesgo y rentabilidad | Explicaciones basadas en reglas transparentes (sin IA externa) |

Todos los módulos comparten el **mismo proyecto**: un cambio en el flujo de caja se refleja en indicadores, riesgo y analista.

## Tecnologías

- **Flutter** (canal estable) y **Dart**.
- **Material 3**, interfaz en español, diseño adaptable a teléfonos.
- **Android** como plataforma objetivo.
- **Sin dependencias externas** de ejecución: funciona 100 % sin conexión.
- Estado con `ChangeNotifier` + `ListenableBuilder` (sin paquetes de terceros).
- Pruebas con `flutter_test`; análisis estático con `flutter_lints`.
- CI/CD con **GitHub Actions**.

## Estructura

```
lib/
  main.dart            Punto de entrada
  app.dart             MaterialApp y tema
  models/              Datos: proyecto, flujo, indicadores, escenarios, casos
  calculators/         Cálculos puros: flujo, VAN, TIR, recuperación, escenarios, validación
  services/            Estado, analista por reglas, casos, evaluador, formato
  screens/             Pantallas de los módulos
  widgets/             Componentes reutilizables (formulario, tablas, gráficos)
test/                  Pruebas unitarias y de widget
docs/README.md         Guía de uso y fundamentos
.github/workflows/     flutter_ci.yml y build_apk.yml
```

## Cómo ejecutar la aplicación

Requisitos: Flutter estable instalado, Android SDK y un emulador o teléfono.

```bash
flutter pub get
flutter run
```

## Cómo ejecutar las pruebas

```bash
flutter test
```

Control de calidad completo (lo mismo que ejecuta `flutter_ci.yml`):

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

> Si `dart format` reporta cambios, ejecuta `dart format .` una vez y haz commit.

## Cómo generar el APK

### Localmente

```bash
flutter build apk --release
```

Se genera **un único APK**:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Con GitHub Actions

1. Sube el proyecto a GitHub (rama `main`).
2. Ve a **Actions → Build APK → Run workflow**, o crea un tag: `git tag v1.0.0 && git push origin v1.0.0`.
3. Descarga el artifact **`ecocapital-apk`**, que contiene solo `app-release.apk`.

El APK release se firma con la clave de depuración para no requerir secretos. Para publicar en una tienda, configura una firma propia.

## Advertencia educativa y financiera

EcoCapital es exclusivamente educativa. Los proyectos, casos, tasas y resultados son ficticios y simplificados (sin impuestos, inflación, depreciación ni financiamiento). **Ningún resultado debe usarse para decisiones de inversión reales.** Para decisiones financieras reales consulta a un profesional autorizado.

## Licencia y versión

Versión 1.0.0 — ver `CHANGELOG.md`.
