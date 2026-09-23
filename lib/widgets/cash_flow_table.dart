import 'package:flutter/material.dart';

import '../models/cash_flow.dart';
import '../services/formatters.dart';

/// Tabla del flujo de caja con desplazamiento horizontal.
class CashFlowTable extends StatelessWidget {
  const CashFlowTable({super.key, required this.cashFlow});

  final CashFlow cashFlow;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
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
              cells: [
                DataCell(Text('${row.period}')),
                DataCell(Text(Formatters.money(row.income))),
                DataCell(Text(Formatters.money(row.cost))),
                DataCell(_amount(row.netFlow, errorColor)),
                DataCell(_amount(row.cumulativeFlow, errorColor)),
                DataCell(_amount(row.discountedFlow, errorColor)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _amount(double value, Color negativeColor) {
    return Text(
      Formatters.money(value),
      style: TextStyle(color: value < 0 ? negativeColor : null),
    );
  }
}
