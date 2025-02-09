// workout_model.dart
class WorkoutPlan {
  final String id;
  final String funFacts;
  final String waktuLatihan;
  final List<String> tutorial;
  final String nama;
  final List<String> energiYangdigunakan;
  final List<String> alat;
  final String fileURL;
  final String kategori;
  final String fotoWO;

  WorkoutPlan({
    required this.id,
    required this.funFacts,
    required this.waktuLatihan,
    required this.tutorial,
    required this.nama,
    required this.energiYangdigunakan,
    required this.alat,
    required this.fileURL,
    required this.kategori,
    required this.fotoWO,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] ?? '',
      funFacts: json['funFacts'] ?? '',
      waktuLatihan: json['WaktuLatihan'] ?? '',
      tutorial: List<String>.from(json['tutorial'] ?? []),
      nama: json['nama'] ?? '',
      energiYangdigunakan: List<String>.from(json['energiYangdigunakan'] ?? []),
      alat: List<String>.from(json['alat'] ?? []),
      fileURL: json['fileURL'] ?? '',
      kategori: json['Kategori'] ?? '',
      fotoWO: json['fotoWO'] ?? '',
    );
  }
}
