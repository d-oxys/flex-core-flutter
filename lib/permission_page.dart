// lib/permission_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PermissionPage extends StatefulWidget {
  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  List<dynamic> permissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPermissions();
  }

  Future<void> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      print("Access token not found.");
      return;
    }

    final url = Uri.parse('${dotenv.env['API_URL']}/permissions?limit=10');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            permissions = data['result']['data'];
            isLoading = false;
          });
        }
      } else {
        print('Failed to load permissions: ${response.body}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading permissions: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(8),
              itemCount: permissions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2 / 1.5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final permission = permissions[index]['permission'];
                final approval1 = permissions[index]['approval1'] ?? {};

                return Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.security, color: Colors.teal, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                permission['type'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Divider(thickness: 1, height: 8),
                        _buildInfoRow(
                          label: 'Category',
                          value: permission['category'] ?? 'N/A',
                          textSize: 10,
                        ),
                        _buildInfoRow(
                          label: 'Reason',
                          value: permission['reason'] ?? 'N/A',
                          textSize: 10,
                        ),
                        _buildInfoRow(
                          label: 'From',
                          value: permission['fromdatetime'] ?? 'N/A',
                          textSize: 10,
                        ),
                        Divider(thickness: 1, height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.blueGrey[700], size: 12),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                approval1['app_1'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(
      {required String label, required String value, double textSize = 10}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
