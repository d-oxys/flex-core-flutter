// // lib/login_model.dart

// import 'dart:convert';
// import 'package:elearning_login/splash_screen.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

// class LoginModel {
//   String? _token;
//   String? _accessToken;
//   Map<String, dynamic>? _user;
//   Map<String, dynamic>? _jobrole;
//   Map<String, dynamic>? _division;
//   Map<String, dynamic>? _role;
//   Map<String, dynamic>? _employeeData;

//   String? get token => _token;
//   String? get accessToken => _accessToken;
//   Map<String, dynamic>? get user => _user;
//   Map<String, dynamic>? get jobrole => _jobrole;
//   Map<String, dynamic>? get division => _division;
//   Map<String, dynamic>? get role => _role;
//   Map<String, dynamic>? get employeeData => _employeeData;

//   Future<bool> login(
//       BuildContext context, String username, String password) async {
//     final response = await http.post(
//       Uri.parse('${dotenv.env['API_URL']}/login'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'nip': username,
//         'password': password,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       _token = data['meta']['message']['token'];
//       _accessToken = data['meta']['message']['token'];
//       _user = data['result']['data']['user'];
//       _jobrole = data['result']['data']['jobrole'];
//       _division = data['result']['data']['division'];
//       _role = data['result']['data']['role'];

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString('accessToken', _accessToken!);

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => SplashScreen(
//             loginModel: this,
//             nextRoute: '/home',
//           ),
//         ),
//       );

//       return true;
//     } else {
//       return false;
//     }
//   }

// // lib/login_model.dart

//   Future<void> fetchEmployee(String id) async {
//     print("Fetching employee data for ID: $id"); // Log employee ID

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final accessToken = prefs.getString('accessToken');

//     if (accessToken == null) {
//       throw Exception('Access token not found');
//     }

//     final response = await http.get(
//       Uri.parse('${dotenv.env['API_URL']}/employee/$id'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       _employeeData = data['result']['data'];
//     } else {
//       print("Failed to load employee data: ${response.body}");
//       throw Exception('Failed to load employee data');
//     }
//   }
// }
