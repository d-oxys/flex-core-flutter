import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginModel {
  String? _token;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _employeeData;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get employeeData => _employeeData;

  /// Login Function
  Future<bool> login(
      BuildContext context, String email, String password) async {
    final url = Uri.parse('${dotenv.env['API_URL_FLEX']}/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ok') {
        _token = data['token'];
        _user = data['user'];

        // Save token to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _token!);
        await prefs.setString('user', jsonEncode(_user));

        return true;
      }
    }

    return false;
  }

  /// Fetch Employee Data Function
  Future<void> fetchEmployee(String id) async {
    print("Fetching employee data for ID: $id");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('authToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/employee/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _employeeData = data['result']['data'];
    } else {
      print("Failed to load employee data: ${response.body}");
      throw Exception('Failed to load employee data');
    }
  }
}
