import 'package:flutter/material.dart';
import 'package:domashni_proekt/service/api/api_service.dart';

class IssuerDataProvider with ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _nlp = [];
  Map<String, dynamic> _lstm = {};
  Map<String, dynamic> _technical = {};
  List<Map<String, dynamic>> _issuerData = [];

  List<dynamic> get nlp => _nlp;

  Map<String, dynamic> get lstm => _lstm;

  Map<String, dynamic> get technical => _technical;

  List<Map<String, dynamic>> get issuerData => _issuerData;

  bool get isLoading => _isLoading;

  Future<void> fetchAnalysis(String issuer) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.getAnalysis(issuer);
      if(res['nlp'] == 'No news found') {
        res['nlp'] = [];
      }
      _nlp = res['nlp'];
      _lstm = res['lstm'];
      _technical = res['technical'];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStocksData(String issuer) async {
    _isLoading = true;
    notifyListeners();

    try {
      _issuerData = await ApiService.getStocksData(issuer);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
