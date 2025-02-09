// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HitungKaloriPage extends StatefulWidget {
  @override
  _HitungKaloriPageState createState() => _HitungKaloriPageState();
}

class _HitungKaloriPageState extends State<HitungKaloriPage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  String gender = '';
  double activity = 1.2;
  String goal = '';
  int mealsPerDay = 3;

  bool isLoading = false;
  bool isCalculated = false;

  Map<String, dynamic> nutrition = {
    'calories': 0.0,
    'carbs': 0.0,
    'protein': 0.0,
    'fat': 0.0,
    'bmiCategory': '',
    'advice': '',
    'idealWeight': 0.0,
    'meals': [],
  };

  void validateForm() {
    if (ageController.text.isEmpty ||
        weightController.text.isEmpty ||
        heightController.text.isEmpty ||
        gender.isEmpty ||
        activity == 0 ||
        goal.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Harap isi semua field!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      calculateCalories();
    }
  }

  Future<void> calculateCalories() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${dotenv.env['API_URL_FLEX']}/calculateCalories');
    final body = jsonEncode({
      'age': int.parse(ageController.text),
      'weight': double.parse(weightController.text),
      'height': double.parse(heightController.text),
      'gender': gender,
      'activity': activity,
      'goal': goal,
      'mealsPerDay': mealsPerDay,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nutrition = data;
          isCalculated = true;
        });
        Fluttertoast.showToast(
          msg: 'Data berhasil dihitung!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Gagal menghitung data. Cek input Anda.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Terjadi kesalahan. Coba lagi nanti.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hitung Kebutuhan Kalori',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masukkan Data Anda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Usia (Tahun)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Berat Badan (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tinggi Badan (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(
                          value: '', child: Text('Pilih Jenis Kelamin')),
                      DropdownMenuItem(value: 'male', child: Text('Pria')),
                      DropdownMenuItem(value: 'female', child: Text('Wanita')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: activity,
                    items: const [
                      DropdownMenuItem(
                          value: 1.2, child: Text('Tidak ada olahraga')),
                      DropdownMenuItem(
                          value: 1.375, child: Text('Olahraga ringan')),
                      DropdownMenuItem(
                          value: 1.55, child: Text('Olahraga sedang')),
                      DropdownMenuItem(
                          value: 1.725, child: Text('Olahraga berat')),
                      DropdownMenuItem(
                          value: 1.9, child: Text('Latihan berat')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        activity = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Aktivitas Fisik',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: goal,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Pilih Tujuan')),
                      DropdownMenuItem(
                          value: 'deficit', child: Text('Defisit Kalori')),
                      DropdownMenuItem(
                          value: 'surplus', child: Text('Surplus Kalori')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        goal = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Tujuan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: validateForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Hitung Kalori',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isCalculated) ...[
                    const Divider(thickness: 2),
                    Center(
                      child: Text(
                        'Hasil Perhitungan',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Berat Anda Tergolong: ',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${nutrition['bmiCategory']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                text: 'Saran: ',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '${nutrition['advice']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                text: 'Berat Badan Ideal Anda: ',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text:
                                        '${nutrition['idealWeight'].toStringAsFixed(2)} kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.teal,
                            width: 8,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Total Energi'),
                              Text(
                                '${nutrition['calories'].toStringAsFixed(2)} kkal',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NutritionBox(
                          label: 'Karbohidrat',
                          value: nutrition['carbs'].toStringAsFixed(2),
                        ),
                        const SizedBox(width: 16),
                        NutritionBox(
                          label: 'Protein',
                          value: nutrition['protein'].toStringAsFixed(2),
                        ),
                        const SizedBox(width: 16),
                        NutritionBox(
                          label: 'Lemak',
                          value: nutrition['fat'].toStringAsFixed(2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Konsumsi Gizi Seimbang yang Disarankan',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<int>(
                      value: mealsPerDay,
                      onChanged: (value) {
                        setState(() {
                          mealsPerDay = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 2, child: Text('2 kali sehari')),
                        DropdownMenuItem(
                            value: 3, child: Text('3 kali sehari')),
                        DropdownMenuItem(
                            value: 4, child: Text('4 kali sehari')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      nutrition['meals'].length,
                      (index) {
                        final meal = nutrition['meals'][index];
                        return MealBox(
                          time: 'Makan ke-${index + 1}',
                          energy: meal['calories'].toStringAsFixed(2),
                          carbs: meal['carbs'].toStringAsFixed(2),
                          fat: meal['fat'].toStringAsFixed(2),
                          protein: meal['protein'].toStringAsFixed(2),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class NutritionBox extends StatelessWidget {
  final String label;
  final String value;

  const NutritionBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Text(
          '$value g',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class MealBox extends StatelessWidget {
  final String time;
  final String energy;
  final String carbs;
  final String fat;
  final String protein;

  const MealBox({
    required this.time,
    required this.energy,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Mengatur lebar penuh
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Energi: $energy kkal'),
              Text('Karbohidrat: $carbs g'),
              Text('Protein: $protein g'),
              Text('Lemak: $fat g'),
            ],
          ),
        ),
      ),
    );
  }
}
