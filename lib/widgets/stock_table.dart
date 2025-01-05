import 'package:flutter/material.dart';

class StockDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> jsonData;

  const StockDataTable({
    super.key,
    required this.jsonData,
  });

  @override
  State<StockDataTable> createState() => _StockDataTableState();
}

class _StockDataTableState extends State<StockDataTable> {
  bool isExpanded = false;

  List<DataColumn> _buildColumns(bool isExpanded) {
    return isExpanded
        ? [
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Close')),
      const DataColumn(label: Text('Max')),
      const DataColumn(label: Text('Min')),
      const DataColumn(label: Text('Avg')),
      const DataColumn(label: Text('Change %')),
      const DataColumn(label: Text('Volume')),
      const DataColumn(label: Text('Turnover')),
      const DataColumn(label: Text('Total')),
    ]
        : [
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Close')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => setState(() => isExpanded = !isExpanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Text(
              isExpanded ? 'Show Less' : 'Show Details',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          // height: 400,
          child: PaginatedDataTable(
            header: Text(isExpanded ? 'Detailed Data' : 'Summary Data'),
            columns: _buildColumns(isExpanded),
            source: _StockDataSource(widget.jsonData, isExpanded),
            rowsPerPage: 10, // Adjust rows per page as needed
          ),
        ),
      ],
    );
  }
}

class _StockDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final bool isExpanded;

  _StockDataSource(this.data, this.isExpanded);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final rowData = data[index];
    return DataRow(cells: [
      DataCell(Text(rowData['date'] ?? '-')),
      DataCell(Text(rowData['lastTradePrice'] ?? '-')),
      if (isExpanded) ...[
        DataCell(Text(rowData['maxPrice'] ?? '-')),
        DataCell(Text(rowData['minPrice'] ?? '-')),
        DataCell(Text(rowData['avgPrice'] ?? '-')),
        DataCell(Text(rowData['percentChange'] ?? '-')),
        DataCell(Text(rowData['volume'] ?? '-')),
        DataCell(Text(rowData['turnoverBest'] ?? '-')),
        DataCell(Text(rowData['totalTurnover'] ?? '-')),
      ]
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
