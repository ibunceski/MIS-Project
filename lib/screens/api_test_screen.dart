import 'package:flutter/material.dart';
import '../service/api/api_service.dart';

class TestApiScreen extends StatefulWidget {
  @override
  _TestApiScreenState createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _callApi(String action) async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      if (action == 'getIssuers') {
        final result = await ApiService.getIssuers();
        setState(() {
          _result = result;
        });
      } else if (action == 'fillData') {
        final result = await ApiService.fillData();
        setState(() {
          _result = result;
        });
      } else if (action == 'getStocksData') {
        final result = await ApiService.getStocksData('ALK');
        setState(() {
          _result = result.map((data) => data.toString()).join('\n');
        });
      } else if (action == 'getAnalysis') {
        final result = await ApiService.getAnalysis('MPT');
        setState(() {
          _result = result.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            if (value is List) {
              return '$key: \n${value.map((item) => item.toString()).join('\n')}';
            } else {
              return '$key: $value';
            }
          }).join('\n\n');
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : () => _callApi('getIssuers'),
              child: Text('Call getIssuers'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _callApi('fillData'),
              child: Text('Call fillData'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _callApi('getStocksData'),
              child: Text('Call getStocksData'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _callApi('getAnalysis'),
              child: Text('Call getAnalysis'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
