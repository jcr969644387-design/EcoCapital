# Changelog

Todos los cambios relevantes de EcoCapital se documentan en este archivo.

## [1.0.3] - 2026-09-22

### Cambiado

- Interfaz renovada: tema azul marino y esmeralda propio del área de Economía y Finanzas, tarjetas redondeadas, íconos coherentes y colores semánticos (verde crea valor, rojo destruye valor, ámbar alerta).
- Pantalla principal con cabecera que resume en vivo el proyecto (VAN, TIR, nivel de riesgo y veredicto) y ruta de aprendizaje numerada.
- Métricas destacadas, gráfico de flujo de caja animado, barras de escenarios animadas, tablas con encabezado resaltado y transiciones suaves entre pantallas y resultados.
- Casos de decisión con opciones en tarjetas y resultado animado según el acierto.

### Añadido

- Sonidos breves y discretos en pulsaciones, selección de opciones, simulaciones, confirmaciones y respuestas (correcta, parcial, incorrecta). Respetan el modo silencio del teléfono.
- Vibración háptica en las mismas interacciones, adaptada a las capacidades del dispositivo (motor de vibración e intensidad).
- Ajustes de **Sonido y vibración** (ícono de ajustes en la pantalla principal), guardados en el dispositivo.
- Pruebas que verifican que el sonido y la vibración se disparan en las interacciones reales.

## [1.0.0] - 2026-09-22

### Añadido

- Módulo **Flujo de caja**: inversión inicial, ingresos, costos, vida del proyecto, crecimiento de ingresos, flujo neto, flujo acumulado, flujo descontado y gráfico.
- Módulo **Indicadores**: VAN, TIR, retorno acumulado, periodo de recuperación simple y descontado, margen de rentabilidad, con explicaciones en lenguaje sencillo y prueba de sensibilidad de la tasa de descuento.
- Módulo **Riesgo**: nivel de riesgo como prima sobre la tasa de descuento y comparación de escenarios pesimista, base y optimista.
- Módulo **Decisiones**: seis casos ficticios con decisión invertir / no invertir / revisar, análisis opcional y retroalimentación explicada.
- Módulo **Analista financiero local**: explicaciones basadas en reglas, sin IA externa ni conexión a internet.
- Pruebas unitarias de cálculos, analista y evaluador de decisiones; pruebas de widget.
- Workflows de GitHub Actions: `flutter_ci.yml` y `build_apk.yml` (APK único `app-release.apk`).
