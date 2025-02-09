// workout_list_container.dart
import 'package:elearning_login/workout/workout_detail_page.dart';
import 'package:flutter/material.dart';
import '../main_layout.dart';
import '../login_model.dart';
import 'workout_service.dart';
import 'workout_model.dart';
import './add_workout_modal.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WorkoutListContainer extends StatelessWidget {
  final LoginModel loginModel;

  const WorkoutListContainer({Key? key, required this.loginModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Workout List',
      loginModel: loginModel,
      body: WorkoutListPage(),
    );
  }
}

class WorkoutListPage extends StatefulWidget {
  @override
  _WorkoutListPageState createState() => _WorkoutListPageState();
}

class _WorkoutListPageState extends State<WorkoutListPage> {
  final WorkoutService _workoutService = WorkoutService();
  List<WorkoutPlan> allWorkouts = [];
  List<WorkoutPlan> filteredWorkouts = [];
  bool isLoading = false;
  int limit = 10;
  String? selectedCategory = 'Semua';
  final List<String> categories = [
    'Semua',
    'Lengan',
    'Dada',
    'Kaki',
    'Punggung'
  ];

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  void filterWorkouts() {
    setState(() {
      if (selectedCategory == null || selectedCategory == 'Semua') {
        filteredWorkouts = allWorkouts;
      } else {
        filteredWorkouts = allWorkouts
            .where((workout) =>
                workout.kategori.toLowerCase() ==
                selectedCategory!.toLowerCase())
            .toList();
      }

      if (filteredWorkouts.length > limit) {
        filteredWorkouts = filteredWorkouts.sublist(0, limit);
      }
    });
  }

  Future<void> fetchWorkouts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedWorkouts = await _workoutService.fetchWorkouts(
        limit: 100,
      );

      setState(() {
        allWorkouts = fetchedWorkouts;
        filterWorkouts();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching workouts: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to load workouts. Please try again later.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showAddWorkoutModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddWorkoutModal(
          onSuccess: () {
            fetchWorkouts();
            Fluttertoast.showToast(
              msg: 'Workout berhasil ditambahkan',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Refrensi Latihan Workout',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Temukan Kekuatan Anda.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mulailah perjalanan kebugaran Anda dengan kami. Dengan berbagai latihan dan komunitas yang mendukung, kami siap membantu Anda mencapai tujuan kebugaran Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
                filterWorkouts();
              });
            },
          ),
          SizedBox(width: 16),
          DropdownButton<int>(
            value: limit,
            items: [5, 10, 20].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value'),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  limit = newValue;
                  filterWorkouts();
                });
              }
            },
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: _showAddWorkoutModal,
            child: Text(
              'Tambah Artikel',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutPlan workout) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutDetailPage(workout: workout),
                      ),
                    );

                    if (result == true) {
                      await fetchWorkouts();
                      if (mounted) {
                        Fluttertoast.showToast(
                          msg: 'Workout berhasil dihapus',
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                      }
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      workout.fileURL,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),
                ),
                // Delete button dengan ukuran lebih kecil
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Hapus'),
                                content: Text(
                                    'Apakah Anda yakin ingin menghapus workout ini?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Batal'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true) {
                            try {
                              await _workoutService.deleteWorkout(workout.id);
                              await fetchWorkouts();
                              if (mounted) {
                                Fluttertoast.showToast(
                                  msg: 'Workout berhasil dihapus',
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Fluttertoast.showToast(
                                  msg: 'Gagal menghapus workout',
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );
                              }
                            }
                          }
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kategori: ${workout.kategori}',
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        workout.funFacts,
                        style: TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutGrid() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (filteredWorkouts.isEmpty) {
      return Center(
        child: Text(
          'No workouts found',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredWorkouts.length,
      itemBuilder: (context, index) =>
          _buildWorkoutCard(filteredWorkouts[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchWorkouts,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              _buildHeader(),
              _buildFilters(),
              SizedBox(height: 12),
              _buildWorkoutGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
