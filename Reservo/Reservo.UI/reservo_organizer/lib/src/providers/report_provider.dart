import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_organizer/src/models/report_models/report_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


enum ReportView { monthly, daily }

class ReportProvider with ChangeNotifier {
  static const String baseUrl = 'http://localhost:5113/Reports';
  ReportView _currentView = ReportView.monthly;
  ReportView get currentView => _currentView;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  
  List<ProfitByCategory> categories = [];
  List<dynamic> lineData = [];

  int year = DateTime.now().year;
  int month = DateTime.now().month;

  bool isLoading = false;

  Future<Map<String, String>> createHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<ProfitByCategory>> getProfitByCategory(int year, {int? month}) async {
    final uri = Uri.parse("$baseUrl/ProfitByCategory?year=$year${month != null ? "&month=$month" : ""}");
    final response = await http.get(
      uri,
      headers: await createHeaders()
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProfitByCategory.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch ProfitByCategory");
    }
  }

  Future<List<ProfitByMonth>> getProfitByMonth(int year) async {
    final uri = Uri.parse("$baseUrl/ProfitByMonth?year=$year");
    final response = await http.get(
      uri,
      headers: await createHeaders()
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProfitByMonth.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch ProfitByMonth");
    }
  }

  Future<List<ProfitByDay>> getProfitByDay(int year, int month) async {
    final uri = Uri.parse("$baseUrl/ProfitByDay?year=$year&month=$month");
    final response = await http.get(
      uri,
      headers: await createHeaders()
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProfitByDay.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch ProfitByDay");
    }
  }

  Future<void> loadReports() async {
    isLoading = true;
    notifyListeners();

    if (_currentView == ReportView.monthly) {
      categories = await getProfitByCategory(year);
      lineData = await getProfitByMonth(year);
    } else {
      categories = await getProfitByCategory(year, month: month);
      lineData = await getProfitByDay(year, month);
    }

    isLoading = false;
    notifyListeners();
  }

  void switchView(ReportView view) {
    _currentView = view;
    loadReports();
  }
  
  void setYear(int newYear) {
    year = newYear;
    loadReports();
  }

  void setMonth(int newMonth) {
    month = newMonth;
    if (_currentView == ReportView.daily) {
      loadReports();
    }
  }
}