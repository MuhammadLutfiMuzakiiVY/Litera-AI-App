import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';

class StudentNavigationBar extends StatelessWidget {
  const StudentNavigationBar({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        switch (index) {
          case 0:
            context.push(RouteNames.studentDashboard);
            break;
          case 1:
            context.push(RouteNames.learningPath);
            break;
          case 2:
            context.push(RouteNames.learningHistory);
            break;
          case 3:
            context.push(RouteNames.aiProfile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.route_outlined),
          selectedIcon: Icon(Icons.route),
          label: 'Path',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Akun',
        ),
      ],
    );
  }
}

class TeacherNavigationBar extends StatelessWidget {
  const TeacherNavigationBar({required this.selectedIndex, super.key});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        switch (index) {
          case 0:
            context.push(RouteNames.teacherDashboard);
            break;
          case 1:
            context.push('/teacher/classes/demo-class');
            break;
          case 2:
            context.push('/teacher/students/demo-student');
            break;
          case 3:
            context.push(RouteNames.aiProfile);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Kelas',
        ),
        NavigationDestination(
          icon: Icon(Icons.priority_high_outlined),
          selectedIcon: Icon(Icons.priority_high),
          label: 'Intervensi',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Akun',
        ),
      ],
    );
  }
}
