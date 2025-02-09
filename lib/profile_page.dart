// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'login_model.dart';

class ProfilePage extends StatefulWidget {
  final String employeeId;
  final LoginModel loginModel;

  ProfilePage({required this.employeeId, required this.loginModel});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<void> _fetchEmployeeFuture;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeFuture = widget.loginModel.fetchEmployee((widget.employeeId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _fetchEmployeeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final employee = widget.loginModel.employeeData?['employee'];
            final personalData =
                widget.loginModel.employeeData?['personal_data'];
            final balance = personalData?['balance'] ?? {};
            final birthDate = personalData?['birth']?['date_of_birth'] ?? 'N/A';
            final superior = personalData?['superior']?['name'] ?? 'N/A';

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Bagian Atas (Foto Profil dan Statistik Balance)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                            'assets/profile_placeholder.png'), // Placeholder image
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Balance', // Header Balance
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${balance['health'] ?? 0}', // Health Balance
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Health'),
                                ],
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  Text(
                                    '${balance['leave_annual'] ?? 0}', // Annual Leave
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Annual'),
                                ],
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  Text(
                                    '${balance['leave_birthday'] ?? 0}', // Birthday Leave
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Birthday'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Nama dan Info Singkat
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${employee?['name'] ?? 'N/A'}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Office Email: ${employee?['emailKantor'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Birthday: $birthDate',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Superior: $superior',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Tombol Edit Profile
                  OutlinedButton(
                    onPressed: () {},
                    child: Text('Edit Profile'),
                  ),
                  SizedBox(height: 16),

                  // Grid Postingan
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Jumlah kolom
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: 12, // Ganti dengan jumlah postingan
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
