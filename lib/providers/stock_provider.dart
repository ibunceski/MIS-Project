import 'package:flutter/material.dart';
import '../model/issuer.dart';
import 'dart:convert';
import '../service/api/api_service.dart';

class StockProvider with ChangeNotifier {
  List<Issuer> _issuers = [];

  List<Issuer> get issuers => _issuers;

  Future<void> fetchIssuers() async {
    try {
      final List<dynamic> data = json.decode(await ApiService.getIssuers());
      _issuers = data.map((json) => Issuer.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching issuers: $e');
    }
  }

  Future<void> updateData() async {
    try {
      await ApiService.fillData();
      await fetchIssuers();
    } catch (e) {
      print('Error updating data: $e');
    }
  }
}
