import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ApiService {
  static Future<String> getIssuers() async {
    final response =
        await http.get(Uri.parse("${dotenv.env['API_URL']}/api/issuers"));
    return response.body;
  }

  static Future<String> fillData() async {
    final response =
        await http.get(Uri.parse("${dotenv.env['API_URL']}/api/fill-data"));
    return response.body;
  }

  static Future<List<Map<String, dynamic>>> getStocksData(String symbol) async {
    final response = await http.get(
      Uri.parse("${dotenv.env['API_URL']}/api/issuer-data/$symbol"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final typedData = jsonData.cast<Map<String, dynamic>>();

      return typedData
        ..sort((a, b) {
          final dateA = DateTime.parse(a['date'].replaceAll('/', '-'));
          final dateB = DateTime.parse(b['date'].replaceAll('/', '-'));
          return dateB.compareTo(dateA);
        });
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<Map<String, dynamic>> getAnalysis(String symbol) async {
    final nlp = await http.get(
      Uri.parse("${dotenv.env['API_URL']}/api/nlp/$symbol"),
    );
    final lstm = await http.get(
      Uri.parse("${dotenv.env['API_URL']}/api/lstm/$symbol"),
    );
    final technical = await http.get(
      Uri.parse("${dotenv.env['API_URL']}/api/technical/$symbol"),
    );

    if (nlp.statusCode == 200 &&
        lstm.statusCode == 200 &&
        technical.statusCode == 200) {
      final nlpData = json.decode(nlp.body);
      final lstmData = json.decode(lstm.body);
      final technicalData = json.decode(technical.body);

      return {
        'nlp': nlpData,
        'lstm': lstmData,
        'technical': technicalData,
      };
    } else {
      throw Exception('Failed to load data');
    }
  }
}
