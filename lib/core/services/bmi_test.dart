import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach/core/models/bmi_calculator.dart';

void main() {
  group('BMI Calculator Tests', () {
    test('Calculate BMI with metric units', () {
      final calculator = BmiCalculator(
        height: 170, // cm
        weight: 70, // kg
        unitSystem: UnitSystem.metric,
      );
      
      final bmi = calculator.calculate();
      
      // BMI = 70 / (1.7 * 1.7) = 24.22
      expect(bmi, closeTo(24.22, 0.1));
      expect(calculator.getCategory(), equals(BmiCategory.normal));
      expect(calculator.getCategoryDescription(), equals('Normal'));
    });
    
    test('Calculate BMI with imperial units', () {
      final calculator = BmiCalculator(
        height: 67, // inches
        weight: 154, // lbs
        unitSystem: UnitSystem.imperial,
      );
      
      final bmi = calculator.calculate();
      
      // BMI = 703 * 154 / (67 * 67) = 24.11
      expect(bmi, closeTo(24.11, 0.1));
      expect(calculator.getCategory(), equals(BmiCategory.normal));
      expect(calculator.getCategoryDescription(), equals('Normal'));
    });
    
    test('BMI category: Underweight', () {
      final calculator = BmiCalculator(
        height: 180, // cm
        weight: 55, // kg
        unitSystem: UnitSystem.metric,
      );
      
      final bmi = calculator.calculate();
      
      // BMI = 55 / (1.8 * 1.8) = 16.98
      expect(bmi, closeTo(16.98, 0.1));
      expect(calculator.getCategory(), equals(BmiCategory.underweight));
      expect(calculator.getCategoryDescription(), equals('Underweight'));
    });
    
    test('BMI category: Overweight', () {
      final calculator = BmiCalculator(
        height: 165, // cm
        weight: 75, // kg
        unitSystem: UnitSystem.metric,
      );
      
      final bmi = calculator.calculate();
      
      // BMI = 75 / (1.65 * 1.65) = 27.55
      expect(bmi, closeTo(27.55, 0.1));
      expect(calculator.getCategory(), equals(BmiCategory.overweight));
      expect(calculator.getCategoryDescription(), equals('Overweight'));
    });
    
    test('BMI category: Obese', () {
      final calculator = BmiCalculator(
        height: 170, // cm
        weight: 95, // kg
        unitSystem: UnitSystem.metric,
      );
      
      final bmi = calculator.calculate();
      
      // BMI = 95 / (1.7 * 1.7) = 32.87
      expect(bmi, closeTo(32.87, 0.1));
      expect(calculator.getCategory(), equals(BmiCategory.obese));
      expect(calculator.getCategoryDescription(), equals('Obese'));
    });
    
    test('Handle zero height', () {
      final calculator = BmiCalculator(
        height: 0, // cm
        weight: 70, // kg
        unitSystem: UnitSystem.metric,
      );
      
      final bmi = calculator.calculate();
      
      // Should return 0 to avoid division by zero
      expect(bmi, equals(0));
    });
  });
}
