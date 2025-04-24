import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/core/theme/app_theme.dart';
import 'package:fitness_coach/core/models/bmi_calculator.dart';
import 'package:fitness_coach/core/services/exercise_service.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final unitSystem = ref.watch(unitSystemProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                // Dark mode toggle
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state = 
                        value ? ThemeMode.dark : ThemeMode.light;
                    
                    // Save preference
                    final box = Hive.box('appSettings');
                    box.put('darkMode', value);
                  },
                  secondary: Icon(
                    themeMode == ThemeMode.dark 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Units section
          _buildSectionHeader(context, 'Units'),
          Card(
            child: Column(
              children: [
                // Unit system toggle
                SwitchListTile(
                  title: const Text('Metric System'),
                  subtitle: const Text('Toggle between metric and imperial units'),
                  value: unitSystem == UnitSystem.metric,
                  onChanged: (value) {
                    final newUnitSystem = value 
                        ? UnitSystem.metric 
                        : UnitSystem.imperial;
                    ref.read(unitSystemProvider.notifier).state = newUnitSystem;
                    
                    // Save preference
                    final box = Hive.box('appSettings');
                    box.put('isMetric', value);
                  },
                  secondary: const Icon(Icons.straighten),
                ),
                
                // Unit explanation
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unitSystem == UnitSystem.metric 
                            ? 'Using Metric Units' 
                            : 'Using Imperial Units',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        unitSystem == UnitSystem.metric 
                            ? '• Height in centimeters (cm)\n• Weight in kilograms (kg)' 
                            : '• Height in inches (in)\n• Weight in pounds (lbs)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Data section
          _buildSectionHeader(context, 'Data'),
          Card(
            child: Column(
              children: [
                // Clear cache
                ListTile(
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Delete all cached exercise data'),
                  leading: const Icon(Icons.delete_outline),
                  onTap: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cache'),
                        content: const Text(
                          'Are you sure you want to clear all cached exercise data? '
                          'You will need an internet connection to reload the data.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      // Clear exercise cache
                      await ref.read(exerciseServiceProvider).clearCache();
                      
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cache cleared successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
                
                // Reset stats
                ListTile(
                  title: const Text('Reset Stats'),
                  subtitle: const Text('Reset all workout statistics'),
                  leading: const Icon(Icons.refresh),
                  onTap: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Stats'),
                        content: const Text(
                          'Are you sure you want to reset all workout statistics? '
                          'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      // Reset stats
                      final box = Hive.box('appSettings');
                      await box.put('totalWorkouts', 0);
                      await box.put('averageBmi', 0.0);
                      
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stats reset successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // About section
          _buildSectionHeader(context, 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  leading: const Icon(Icons.info_outline),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Developer'),
                  subtitle: const Text('Fitness Coach Team'),
                  leading: const Icon(Icons.code),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
