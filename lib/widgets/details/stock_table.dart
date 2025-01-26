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
      DataColumn(label: Text('Date', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Close', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Max', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Min', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Avg', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Change %', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Volume', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Turnover', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Total', style: TextStyle(color: Colors.blue.shade900))),
    ]
        : [
      DataColumn(label: Text('Date', style: TextStyle(color: Colors.blue.shade900))),
      DataColumn(label: Text('Close', style: TextStyle(color: Colors.blue.shade900))),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(
              isExpanded ? 'Show Less' : 'Show Details',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: PaginatedDataTable(
            header: Text(
              isExpanded ? 'Detailed Data' : 'Summary Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            columns: _buildColumns(isExpanded),
            source: _StockDataSource(widget.jsonData, isExpanded),
            rowsPerPage: 10,
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
      DataCell(Text(rowData['date'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
      DataCell(Text(rowData['lastTradePrice'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
      if (isExpanded) ...[
        DataCell(Text(rowData['maxPrice'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['minPrice'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['avgPrice'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['percentChange'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['volume'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['turnoverBest'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
        DataCell(Text(rowData['totalTurnover'] ?? '-', style: TextStyle(color: Colors.blue.shade900))),
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