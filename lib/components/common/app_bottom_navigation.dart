import 'package:flutter/material.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: AppTheme.labelMedium,
      unselectedLabelStyle: AppTheme.labelMedium,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Leave',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Report',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

class AppBottomNavigationWithRoutes extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationWithRoutes({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigation(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, AppRouter.dashboard);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, AppRouter.attendance);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, AppRouter.leave);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, AppRouter.report);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, AppRouter.settings);
            break;
        }
      },
    );
  }
} 