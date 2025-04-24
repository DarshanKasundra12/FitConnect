import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/core/models/exercise.dart';

class ExerciseService {
  final Dio _dio = Dio();
  final Box _cacheBox = Hive.box('exerciseCache');
  
  // Base URL for the wger API
  final String _baseUrl = 'https://wger.de/api/v2';
  
  // Fetch exercises with optional filter
  Future<List<Exercise>> getExercises({String? bodyPart}) async {
    try {
      // Check cache first
      final cacheKey = 'exercises_${bodyPart ?? 'all'}';
      final cachedData = _cacheBox.get(cacheKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded.map((e) => Exercise.fromJson(e)).toList();
      }
      
      // If not in cache, fetch from API
      String url = '$_baseUrl/exercise/?language=2&limit=20';
      
      if (bodyPart != null && bodyPart.isNotEmpty) {
        // Add filter for body part/muscle
        url += '&muscles=$bodyPart';
      }
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final exercises = results.map((e) => Exercise.fromJson(e)).toList();
        
        // Cache the results
        await _cacheBox.put(cacheKey, json.encode(results));
        
        return exercises;
      } else {
        // If API call fails, return mock data
        return Exercise.getMockExercises();
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      // Return mock data in case of error
      return Exercise.getMockExercises();
    }
  }
  
  // Get exercise details by ID
  Future<Exercise> getExerciseDetails(int id) async {
    try {
      // Check cache first
      final cacheKey = 'exercise_$id';
      final cachedData = _cacheBox.get(cacheKey);
      
      if (cachedData != null) {
        return Exercise.fromJson(json.decode(cachedData));
      }
      
      // If not in cache, fetch from API
      final response = await _dio.get('$_baseUrl/exercise/$id');
      
      if (response.statusCode == 200) {
        final exercise = Exercise.fromJson(response.data);
        
        // Cache the result
        await _cacheBox.put(cacheKey, json.encode(response.data));
        
        return exercise;
      } else {
        // If API call fails, return a mock exercise
        return Exercise.getMockExercises().firstWhere(
          (e) => e.id == id, 
          orElse: () => Exercise.getMockExercises().first
        );
      }
    } catch (e) {
      print('Error fetching exercise details: $e');
      // Return a mock exercise in case of error
      return Exercise.getMockExercises().first;
    }
  }
  
  // Clear cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}

// Provider for the exercise service
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService();
});

// Provider for exercises list with optional filter
final exercisesProvider = FutureProvider.family<List<Exercise>, String?>((ref, bodyPart) {
  final exerciseService = ref.watch(exerciseServiceProvider);
  return exerciseService.getExercises(bodyPart: bodyPart);
});

// Provider for exercise details
final exerciseDetailsProvider = FutureProvider.family<Exercise, int>((ref, id) {
  final exerciseService = ref.watch(exerciseServiceProvider);
  return exerciseService.getExerciseDetails(id);
});
