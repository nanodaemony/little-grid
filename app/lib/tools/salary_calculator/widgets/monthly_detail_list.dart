import 'package:flutter/material.dart';
import '../models/salary_result.dart';

class MonthlyDetailList extends StatelessWidget {
  final SalaryResult? result;

  const MonthlyDetailList({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '月度明细',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              headingRowHeight: 48,
              columns: const [
                DataColumn(label: Text('月份')),
                DataColumn(label: Text('当月税额')),
                DataColumn(label: Text('累计税额')),
                DataColumn(label: Text('当月税后')),
              ],
              rows: result!.monthlyDetails.map((detail) {
                return DataRow(
                  cells: [
                    DataCell(Text('${detail.month}月')),
                    DataCell(Text('¥${detail.monthlyTax.toStringAsFixed(2)}')),
                    DataCell(Text('¥${detail.cumulativeTax.toStringAsFixed(2)}')),
                    DataCell(Text('¥${detail.monthlyAfterTax.toStringAsFixed(2)}')),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
