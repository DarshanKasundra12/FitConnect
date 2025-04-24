import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/features/home/home_screen.dart';
import 'package:fitness_coach/features/exercises/exercises_screen.dart';
import 'package:fitness_coach/features/bmi/bmi_screen.dart';
import 'package:fitness_coach/features/settings/settings_screen.dart';
import 'package:fitness_coach/shared/utils/responsive.dart';

// Selected tab index provider
final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isTablet = Responsive.isTablet(context);

    // List of screens for each tab
    final screens = [
      const HomeScreen(),
      const ExercisesScreen(),
      const BMIScreen(),
      const SettingsScreen(),
    ];

    // Navigation items
    final navigationItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.fitness_center_outlined),
        selectedIcon: Icon(Icons.fitness_center),
        label: 'Exercises',
      ),
      const NavigationDestination(
        icon: Icon(Icons.monitor_weight_outlined),
        selectedIcon: Icon(Icons.monitor_weight),
        label: 'BMI',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    // Use NavigationRail for tablets and NavigationBar for phones
    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedTab,
              onDestinationSelected: (index) {
                ref.read(selectedTabProvider.notifier).state = index;
              },
              labelType: NavigationRailLabelType.selected,
              destinations: navigationItems
                  .map((item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.selectedIcon,
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            Expanded(
              child: screens[selectedTab],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: screens[selectedTab],
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            ref.read(selectedTabProvider.notifier).state = index;
          },
          destinations: navigationItems,
        ),
      );
    }
  }
}
