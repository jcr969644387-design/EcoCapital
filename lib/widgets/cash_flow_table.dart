import 'package:flutter/material.dart';

import '../models/cash_flow.dart';
import '../services/formatters.dart';
import '../theme/app_theme.dart';

/// Tabla del flujo de caja con desplazamiento horizontal.
class CashFlowTable extends StatelessWidget {
  const CashFlowTable({super.key, required this.cashFlow});

  final CashFlow cashFlow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final negativeColor = FinanceColors.of(context).negative;
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 44,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          headingRowColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.08),
          ),
          headingTextStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
          columns: const [
            DataColumn(label: Text('Año')),
            DataColumn(label: Text('Ingresos'), numeric: true),
            DataColumn(label: Text('Costos'), numeric: true),
            DataColumn(label: Text('Flujo neto'), numeric: true),
            DataColumn(label: Text('Acumulado'), numeric: true),
            DataColumn(label: Text('Descontado'), numeric: true),
          ],
          rows: [
            for (final row in cashFlow.rows)
              DataRow(
                color: row.period.isOdd
                    ? WidgetStatePropertyAll(
                        scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      )
                    : null,
                cells: [
                  DataCell(Text('${row.period}')),
                  DataCell(Text(Formatters.money(row.income))),
                  DataCell(Text(Formatters.money(row.cost))),
                  DataCell(_amount(row.netFlow, negativeColor)),
                  DataCell(_amount(row.cumulativeFlow, negativeColor)),
                  DataCell(_amount(row.discountedFlow, negativeColor)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _amount(double value, Color negativeColor) {
    return Text(
      Formatters.money(value),
      style: TextStyle(
        color: value < 0 ? negativeColor : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
