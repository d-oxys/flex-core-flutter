// lib/widgets/add_workout_modal.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AddWorkoutModal extends StatefulWidget {
  final Function() onSuccess;

  const AddWorkoutModal({Key? key, required this.onSuccess}) : super(key: key);

  @override
  _AddWorkoutModalState createState() => _AddWorkoutModalState();
}

class _AddWorkoutModalState extends State<AddWorkoutModal> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isImageValid = true;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _waktuLatihanController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _funFactsController = TextEditingController();
  final TextEditingController _energiController = TextEditingController();
  final TextEditingController _alatController = TextEditingController();
  final TextEditingController _tutorialController = TextEditingController();

  final List<String> _categories = ['Lengan', 'Dada', 'Kaki', 'Punggung'];

  bool _validateImageFormat(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png'].contains(ext);
  }

  Future<void> _pickImage() async {
    try {
      // Reset image validation state
      setState(() {
        _isImageValid = true;
      });

      // Check platform and request permissions
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
            msg: 'Izin akses galeri diperlukan',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85, // Compress image quality
      );

      if (pickedFile != null) {
        if (!_validateImageFormat(pickedFile.path)) {
          setState(() {
            _isImageValid = false;
          });
          Fluttertoast.showToast(
            msg:
                'Hanya file dengan ekstensi .jpg, .jpeg, atau .png yang diperbolehkan',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
          );
          return;
        }

        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      print('Error picking image: ${e.message}');
      Fluttertoast.showToast(
        msg: 'Gagal memilih gambar: ${e.message}',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(
        msg: 'Terjadi kesalahan saat memilih gambar',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_image == null) {
      Fluttertoast.showToast(
        msg: 'Silakan pilih foto workout terlebih dahulu',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    if (!_isImageValid) {
      Fluttertoast.showToast(
        msg: 'Format gambar tidak valid',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_URL_FLEX']}/workout'),
      );

      // Log API URL
      print('🚀 Sending request to: ${dotenv.env['API_URL_FLEX']}/workout');

      // Handle image upload
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        final filename = _image!.path.split('/').last;

        print('📸 Image details:');
        print('Filename: $filename');
        print('Size: ${bytes.length} bytes');

        var multipartFile = http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Prepare and clean workout data
      final workoutData = {
        'nama': _namaController.text.trim(),
        'WaktuLatihan': _waktuLatihanController.text.trim(),
        'Kategori': _kategoriController.text.trim(),
        'funFacts': _funFactsController.text.trim(),
        'energiYangdigunakan': _energiController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'alat': _alatController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'tutorial': _tutorialController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Log workout data
      print('📦 Workout data being sent:');
      print(JsonEncoder.withIndent('  ').convert(workoutData));

      // Add workout data to request
      request.fields['workout'] = jsonEncode(workoutData);

      // Add necessary headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      // Log request details
      print('📡 Request details:');
      print('URL: ${request.url}');
      print('Headers: ${request.headers}');
      print('Fields count: ${request.fields.length}');
      print('Files count: ${request.files.length}');

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      // Log response
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Parse response
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Show success message
        Fluttertoast.showToast(
          msg: jsonResponse['message'] ?? 'Workout berhasil ditambahkan',
          backgroundColor: Colors.green,
          toastLength: Toast.LENGTH_LONG,
        );

        // Call success callback and close modal
        widget.onSuccess();
        Navigator.of(context).pop();
      } else {
        // Handle error response
        throw Exception(jsonResponse['message'] ?? 'Gagal menambahkan workout');
      }
    } on TimeoutException {
      print('❌ Request timeout');
      Fluttertoast.showToast(
        msg: 'Koneksi timeout. Silakan coba lagi.',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      print('❌ Error during submission: $e');
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      // Reset loading state if component is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambah Workout Plan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Workout *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama workout wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _kategoriController.text.isEmpty
                        ? null
                        : _kategoriController.text,
                    decoration: const InputDecoration(
                      labelText: 'Kategori *',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _kategoriController.text = newValue;
                      }
                    },
                    validator: (value) =>
                        value == null ? 'Pilih kategori workout' : null,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Upload Foto Workout *'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      if (_image != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'File terpilih: ${_image!.path.split('/').last}',
                                style: TextStyle(
                                  color: _isImageValid
                                      ? Colors.grey[600]
                                      : Colors.red,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_image != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _waktuLatihanController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu Latihan *',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: 30 menit',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Waktu latihan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _funFactsController,
                    decoration: const InputDecoration(
                      labelText: 'Fun Facts *',
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan fakta menarik tentang workout ini',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Fun facts wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _energiController,
                    decoration: const InputDecoration(
                      labelText: 'Energi Yang Digunakan *',
                      border: OutlineInputBorder(),
                      hintText:
                          'Pisahkan dengan koma. Contoh: Karbohidrat, Protein, Lemak',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Energi yang digunakan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alatController,
                    decoration: const InputDecoration(
                      labelText: 'Alat Yang Dibutuhkan *',
                      border: OutlineInputBorder(),
                      hintText:
                          'Pisahkan dengan koma. Contoh: Dumbbell, Matras, Tali',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alat yang dibutuhkan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tutorialController,
                    decoration: const InputDecoration(
                      labelText: 'Tutorial *',
                      border: OutlineInputBorder(),
                      hintText:
                          'Pisahkan dengan koma. Contoh: Langkah 1, Langkah 2, Langkah 3',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tutorial wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.blue[200],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan Workout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _waktuLatihanController.dispose();
    _kategoriController.dispose();
    _funFactsController.dispose();
    _energiController.dispose();
    _alatController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }
}
