import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'HitungKalori_page.dart';
import 'login_model.dart';
import 'main_layout.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> articles = [];
  bool isLoading = true;

  // Fetch Articles from API
  Future<void> fetchArticles() async {
    final url = Uri.parse('${dotenv.env['API_URL_FLEX']}/workout?limit=10');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          articles = data['workoutPlans'];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching articles: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null || route.settings.arguments == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Login data not found. Please login again.',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    final loginModel = route.settings.arguments as LoginModel;

    return MainLayout(
      title: 'Home',
      loginModel: loginModel,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              color: const Color(0xFFEAF7FF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    "https://flex-core.vercel.app/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Ftnc_logo.5d72cb3d.png&w=256&q=75",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Selamat Datang di FlexForce",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Yuk Hitung Kebutuhan Kalori Anda!",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HitungKaloriPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2AA8FF),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Hitung Kalori",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/workout',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF32B6C1),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Workout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Articles Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rekomendasi Artikel",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : articles.isEmpty
                          ? const Center(
                              child: Text("Tidak ada artikel ditemukan"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: articles.length,
                              itemBuilder: (context, index) {
                                final article = articles[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Image.network(
                                      article['fileURL'] ?? '',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      article['nama'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      article['funFacts'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),

            // FAQ Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Frequently Asked Questions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final faqs = [
                        {
                          "question": "Apakah FlexForce Gratis?",
                          "answer":
                              "Ya, Aplikasi FlexForce dapat Anda gunakan secara gratis, tanpa biaya pendaftaran atau berlangganan."
                        },
                        {
                          "question":
                              "Apakah Ada Fitur Untuk Menghitung Jumlah Kalori Yang Dibutuhkan?",
                          "answer":
                              "Ya, FlexForce memiliki fitur untuk menghitung jumlah kalori yang dibutuhkan yang dapat Anda gunakan untuk menghitung kebutuhan kalori Anda."
                        },
                        {
                          "question":
                              "Bagaimana Cara Menambahkan Artikel Baru?",
                          "answer":
                              "Untuk menambahkan artikel baru ke FlexForce, Anda perlu membuat akun terlebih dahulu. Setelah itu, Anda dapat mengajukan artikel yang belum tersedia melalui halaman Workout yang tersedia di website."
                        },
                        {
                          "question":
                              "Apakah Aplikasi Ini Menyediakan Contoh Gerakan Workout?",
                          "answer":
                              "Ya, FlexForce menyediakan contoh gerakan workout. Contoh-contoh ini dapat membantu Anda memahami bagaimana workout yang benar."
                        },
                      ];
                      final faq = faqs[index];
                      return ExpansionTile(
                        title: Text(faq['question']!),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(faq['answer']!),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
