import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum UnitSystem { metric, imperial }
enum BmiCategory { underweight, normal, overweight, obese }

class BmiCalculator {
  final double height; // cm or inches
  final double weight; // kg or lbs
  final UnitSystem unitSystem;

  BmiCalculator({
    required this.height,
    required this.weight,
    required this.unitSystem,
  });

  // Calculate BMI
  double calculate() {
    if (height <= 0) return 0;
    
    switch (unitSystem) {
      case UnitSystem.metric:
        // BMI = weight(kg) / height(m)²
        return weight / ((height / 100) * (height / 100));
      case UnitSystem.imperial:
        // BMI = 703 * weight(lbs) / height(inches)²
        return 703 * weight / (height * height);
    }
  }

  // Get BMI category
  BmiCategory getCategory() {
    final bmi = calculate();
    
    if (bmi < 18.5) {
      return BmiCategory.underweight;
    } else if (bmi < 25) {
      return BmiCategory.normal;
    } else if (bmi < 30) {
      return BmiCategory.overweight;
    } else {
      return BmiCategory.obese;
    }
  }

  // Get category description
  String getCategoryDescription() {
    switch (getCategory()) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obese:
        return 'Obese';
    }
  }

  // Get category color
  int getCategoryColor() {
    switch (getCategory()) {
      case BmiCategory.underweight:
        return 0xFF64B5F6; // Blue
      case BmiCategory.normal:
        return 0xFF81C784; // Green
      case BmiCategory.overweight:
        return 0xFFFFB74D; // Orange
      case BmiCategory.obese:
        return 0xFFE57373; // Red
    }
  }
}

// Provider for unit system preference
final unitSystemProvider = StateProvider<UnitSystem>((ref) {
  final box = Hive.box('appSettings');
  final isMetric = box.get('isMetric', defaultValue: true);
  return isMetric ? UnitSystem.metric : UnitSystem.imperial;
});

// Provider for BMI calculator
final bmiCalculatorProvider = Provider.family<BmiCalculator, ({double height, double weight})>((ref, params) {
  final unitSystem = ref.watch(unitSystemProvider);
  return BmiCalculator(
    height: params.height,
    weight: params.weight,
    unitSystem: unitSystem,
  );
});
