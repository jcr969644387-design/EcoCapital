# EcoCapital — Guía de uso y fundamentos

> Aplicación exclusivamente educativa. Escenarios ficticios. No es asesoramiento financiero.

## 1. Guía breve de uso

1. **Abre "Flujo de caja"**. La app inicia con un proyecto de ejemplo. Cambia la inversión, los ingresos, los costos, la vida del proyecto, la tasa base, el crecimiento de ingresos, el escenario y el riesgo. Presiona **Calcular**.
2. **Observa el gráfico y la tabla**: barras = flujo neto de cada año; línea = flujo acumulado. Cuando la línea cruza el cero, la inversión se recuperó.
3. **Ve a "Indicadores"**: toca cada indicador para ver su explicación. Mueve el control de la tasa y observa cómo cae el VAN cuando sube la tasa.
4. **Ve a "Riesgo"**: cambia el nivel de riesgo y compara los tres escenarios.
5. **Practica en "Decisiones"**: lee el caso, activa el análisis (recomendado), decide y lee la retroalimentación. Puedes cargar el caso en el simulador para explorarlo.
6. **Consulta al "Analista financiero"**: elige una pregunta y lee el diagnóstico completo del proyecto actual.

**Sugerencia didáctica:** antes de calcular, anota tu predicción ("¿el VAN será positivo?"). Luego compara con el resultado.

## 2. Descripción de los módulos

### Flujo de caja
- Año 0: `−inversión inicial`.
- Año t: `ingreso_t = ingreso base × factor de escenario × (1 + crecimiento)^(t−1)`; `costo_t = costo base × factor de escenario`.
- Flujo neto = ingreso − costo. Flujo acumulado = suma de flujos netos hasta ese año. Flujo descontado = flujo neto / (1 + tasa)^t.

### Indicadores
VAN, TIR, tasa usada, retorno acumulado, periodo de recuperación simple y descontado, y margen de rentabilidad, cada uno con explicación en lenguaje sencillo. Incluye una **prueba de sensibilidad** de la tasa base (0 % a 40 %).

### Riesgo
El riesgo se modela como **prima sobre la tasa de descuento** y se compara en tres escenarios:

| Escenario | Ingresos | Costos |
|---|---|---|
| Pesimista | −20 % | +10 % |
| Base | igual | igual |
| Optimista | +20 % | −5 % |

| Riesgo | Prima sumada a la tasa |
|---|---|
| Bajo | 0 puntos |
| Medio | 3 puntos |
| Alto | 6 puntos |

### Decisiones
Seis casos ficticios (panadería, tienda de accesorios, planta de empaque, paneles solares, app de delivery, hotel boutique). La decisión recomendada se obtiene con reglas explícitas:

| VAN en escenarios | Veredicto | Decisión recomendada |
|---|---|---|
| Positivo en los tres | Viable | Invertir |
| Positivo en base, negativo en alguno | Viable con riesgo | Revisar |
| No positivo en base, positivo en alguno | Requiere revisión | Revisar |
| Negativo en los tres | No viable | No invertir |

Elegir "Revisar" cuando la respuesta era clara cuenta como **decisión parcial**: es prudente, pero no aprovecha la información disponible. La app también avisa si se decidió sin revisar el análisis.

### Analista financiero local
Aplica reglas transparentes sobre los resultados: signo del VAN, sensibilidad a +2 puntos de tasa, TIR frente a la tasa exigida (TIR "alta" si la supera en más de 15 puntos), cantidad de escenarios positivos y rango del VAN, recuperación frente a la vida del proyecto, y contraste entre ganancia contable y creación de valor. **No usa IA externa, claves ni internet.**

## 3. VAN, TIR y riesgo explicados

**VAN (valor actual neto).** `VAN = Σ Ft / (1 + r)^t`, desde t = 0 hasta n. Trae todos los flujos a valor de hoy con la tasa exigida `r`. VAN > 0: el proyecto rinde más de lo exigido y crea valor. VAN < 0: no alcanza la rentabilidad mínima, aunque tenga ganancias contables.

**TIR (tasa interna de retorno).** Es la tasa que hace VAN = 0. Si TIR > r, el proyecto rinde más que lo exigido. EcoCapital la calcula por bisección. Puede no existir (por ejemplo, si todos los flujos son negativos) y, si los flujos cambian de signo más de una vez, puede no ser única; la app lo advierte. Ante conflicto entre TIR y VAN, se prioriza el VAN.

**Riesgo.** A mayor riesgo, el inversionista exige mayor rentabilidad: la tasa usada es `tasa base + prima por riesgo`. Además, los escenarios muestran qué pasa si ingresos y costos se desvían de lo estimado. Un proyecto robusto mantiene VAN positivo incluso en el escenario pesimista.

**Periodo de recuperación.** Años hasta que el flujo acumulado se vuelve positivo (interpolado dentro del año). Mide liquidez, no rentabilidad. La versión descontada usa flujos descontados.

**Retorno acumulado y margen.** Retorno acumulado = (suma de flujos operativos − inversión) / inversión, sin descontar. Margen = (ingresos − costos) / ingresos totales.

## 4. Supuestos y limitaciones

- Flujos **anuales**, al final de cada año; la inversión ocurre en el año 0.
- Costos constantes; los ingresos pueden crecer a una tasa constante.
- **No incluye** impuestos, depreciación, inflación, capital de trabajo, valor residual ni financiamiento con deuda.
- El riesgo es una **prima fija** por nivel y tres escenarios deterministas; no hay simulación probabilística.
- Moneda de ejemplo: `S/` (configurable en `lib/services/formatters.dart`). Los montos son ficticios.
- El progreso del módulo Decisiones se guarda **solo durante la sesión**.
- El analista usa reglas simplificadas con fines didácticos; sus conclusiones no son recomendaciones de inversión.

## 5. Evolución sugerida (fuera del MVP)

- Flujos editables año por año y valor residual.
- Impuestos y depreciación (flujo de caja económico).
- Análisis de sensibilidad multivariable y simulación Monte Carlo.
- Persistencia del progreso y banco de casos ampliable.
- Evaluar, con criterio pedagógico, un tutor con IA que explique los errores del estudiante.
