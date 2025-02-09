// workout_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import './workout_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkoutService {
  Future<List<WorkoutPlan>> fetchWorkouts({
    String? search,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      String baseUrl = '${dotenv.env['API_URL_FLEX']}/workout';

      // Build query parameters
      final queryParams = [];
      if (search != null && search.isNotEmpty) {
        queryParams.add('q=$search');
      }
      if (limit != 10) {
        queryParams.add('limit=$limit');
      }
      if (skip > 0) {
        queryParams.add('skip=$skip');
      }

      if (queryParams.isNotEmpty) {
        baseUrl += '?' + queryParams.join('&');
      }

      final url = Uri.parse(baseUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok' && data['workoutPlans'] != null) {
          final List<dynamic> workoutPlans = data['workoutPlans'];
          return workoutPlans
              .map((plan) => WorkoutPlan.fromJson(plan))
              .toList();
        }
        return [];
      }
      throw Exception('Failed to fetch workouts: ${response.statusCode}');
    } catch (e) {
      print('Error fetching workouts: $e');
      throw Exception('Error fetching workouts: $e');
    }
  }

  Future<bool> deleteWorkout(String id) async {
    try {
      final url = Uri.parse('${dotenv.env['API_URL_FLEX']}/workout/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'ok';
      }
      throw Exception('Failed to delete workout: ${response.statusCode}');
    } catch (e) {
      print('Error deleting workout: $e');
      throw Exception('Error deleting workout: $e');
    }
  }
}
