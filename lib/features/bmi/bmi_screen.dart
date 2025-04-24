import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/core/models/bmi_calculator.dart';
import 'package:fitness_coach/core/models/workout_stats.dart';
import 'package:fitness_coach/features/bmi/bmi_gauge.dart';

// Height and weight providers
final heightProvider = StateProvider<double>((ref) => 170); // Default 170 cm or 67 inches
final weightProvider = StateProvider<double>((ref) => 70); // Default 70 kg or 154 lbs

// BMI result provider
final bmiResultProvider = StateProvider<double?>((ref) => null);

class BMIScreen extends ConsumerWidget {
  const BMIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitSystem = ref.watch(unitSystemProvider);
    final height = ref.watch(heightProvider);
    final weight = ref.watch(weightProvider);
    final bmiResult = ref.watch(bmiResultProvider);
    
    // Get height and weight labels based on unit system
    final heightLabel = unitSystem == UnitSystem.metric ? 'Height (cm)' : 'Height (in)';
    final weightLabel = unitSystem == UnitSystem.metric ? 'Weight (kg)' : 'Weight (lbs)';
    
    // Get height and weight ranges based on unit system
    final heightRange = unitSystem == UnitSystem.metric 
        ? const RangeValues(120, 220) 
        : const RangeValues(48, 84);
    final weightRange = unitSystem == UnitSystem.metric 
        ? const RangeValues(30, 150) 
        : const RangeValues(66, 330);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: false,
        actions: [
          // Unit toggle
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SegmentedButton<UnitSystem>(
              segments: const [
                ButtonSegment<UnitSystem>(
                  value: UnitSystem.metric,
                  label: Text('Metric'),
                ),
                ButtonSegment<UnitSystem>(
                  value: UnitSystem.imperial,
                  label: Text('Imperial'),
                ),
              ],
              selected: {unitSystem},
              onSelectionChanged: (newSelection) {
                ref.read(unitSystemProvider.notifier).state = newSelection.first;
                
                // Convert values when switching units
                if (newSelection.first == UnitSystem.imperial) {
                  // Convert cm to inches
                  ref.read(heightProvider.notifier).state = height / 2.54;
                  // Convert kg to lbs
                  ref.read(weightProvider.notifier).state = weight * 2.20462;
                } else {
                  // Convert inches to cm
                  ref.read(heightProvider.notifier).state = height * 2.54;
                  // Convert lbs to kg
                  ref.read(weightProvider.notifier).state = weight / 2.20462;
                }
                
                // Clear BMI result
                ref.read(bmiResultProvider.notifier).state = null;
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI explanation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Mass Index (BMI)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMI is a measure of body fat based on height and weight. It applies to adult men and women.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Height input
            Text(
              heightLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: heightRange.start,
                    max: heightRange.end,
                    value: height.clamp(heightRange.start, heightRange.end),
                    onChanged: (value) {
                      ref.read(heightProvider.notifier).state = value;
                      ref.read(bmiResultProvider.notifier).state = null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixText: unitSystem == UnitSystem.metric ? 'cm' : 'in',
                    ),
                    controller: TextEditingController(
                      text: height.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null) {
                        ref.read(heightProvider.notifier).state = parsedValue;
                        ref.read(bmiResultProvider.notifier).state = null;
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Height shortcuts
            Wrap(
              spacing: 8,
              children: [
                if (unitSystem == UnitSystem.metric) ...[
                  _buildHeightShortcut(ref, 160, 'Short'),
                  _buildHeightShortcut(ref, 170, 'Average'),
                  _buildHeightShortcut(ref, 180, 'Tall'),
                ] else ...[
                  _buildHeightShortcut(ref, 63, 'Short'),
                  _buildHeightShortcut(ref, 67, 'Average'),
                  _buildHeightShortcut(ref, 71, 'Tall'),
                ],
              ],
            ),
            const SizedBox(height: 24),
            
            // Weight input
            Text(
              weightLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    min: weightRange.start,
                    max: weightRange.end,
                    value: weight.clamp(weightRange.start, weightRange.end),
                    onChanged: (value) {
                      ref.read(weightProvider.notifier).state = value;
                      ref.read(bmiResultProvider.notifier).state = null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixText: unitSystem == UnitSystem.metric ? 'kg' : 'lbs',
                    ),
                    controller: TextEditingController(
                      text: weight.toStringAsFixed(1),
                    ),
                    onChanged: (value) {
                      final parsedValue = double.tryParse(value);
                      if (parsedValue != null) {
                        ref.read(weightProvider.notifier).state = parsedValue;
                        ref.read(bmiResultProvider.notifier).state = null;
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // Weight shortcuts
            Wrap(
              spacing: 8,
              children: [
                if (unitSystem == UnitSystem.metric) ...[
                  _buildWeightShortcut(ref, 60, 'Light'),
                  _buildWeightShortcut(ref, 75, 'Average'),
                  _buildWeightShortcut(ref, 90, 'Heavy'),
                ] else ...[
                  _buildWeightShortcut(ref, 132, 'Light'),
                  _buildWeightShortcut(ref, 165, 'Average'),
                  _buildWeightShortcut(ref, 198, 'Heavy'),
                ],
              ],
            ),
            const SizedBox(height: 32),
            
            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final calculator = ref.read(bmiCalculatorProvider(
                    (height: height, weight: weight),
                  ));
                  final bmi = calculator.calculate();
                  ref.read(bmiResultProvider.notifier).state = bmi;
                  
                  // Update workout stats with new BMI
                  updateWorkoutStats(ref, bmi: bmi);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Calculate BMI'),
              ),
            ),
            const SizedBox(height: 32),
            
            // BMI result
            if (bmiResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI Result',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // BMI gauge
                      SizedBox(
                        height: 200,
                        child: BMIGauge(bmi: bmiResult),
                      ),
                      const SizedBox(height: 16),
                      
                      // BMI value and category
                      Text(
                        bmiResult.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getBmiColor(bmiResult),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBmiCategory(bmiResult),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getBmiColor(bmiResult),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getBmiDescription(bmiResult),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeightShortcut(WidgetRef ref, double value, String label) {
    return ElevatedButton(
      onPressed: () {
        ref.read(heightProvider.notifier).state = value;
        ref.read(bmiResultProvider.notifier).state = null;
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildWeightShortcut(WidgetRef ref, double value, String label) {
    return ElevatedButton(
      onPressed: () {
        ref.read(weightProvider.notifier).state = value;
        ref.read(bmiResultProvider.notifier).state = null;
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
  
  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
  
  String _getBmiDescription(double bmi) {
    if (bmi < 18.5) {
      return 'You are underweight. Consider gaining some weight through a balanced diet.';
    } else if (bmi < 25) {
      return 'Your weight is normal. Keep up the good work!';
    } else if (bmi < 30) {
      return 'You are overweight. Consider losing some weight through diet and exercise.';
    } else {
      return 'You are obese. It is recommended to consult with a healthcare professional.';
    }
  }
}
