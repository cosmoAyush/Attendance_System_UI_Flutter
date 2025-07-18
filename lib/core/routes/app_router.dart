import 'package:flutter/material.dart';
import 'package:attendance_system_hris/screens/splash_screen.dart';
import 'package:attendance_system_hris/screens/login/login_screen.dart';
import 'package:attendance_system_hris/screens/quick_attendance_screen.dart';
import 'package:attendance_system_hris/screens/forgot_password_screen.dart';
import 'package:attendance_system_hris/screens/dashboard/dashboard_screen.dart';
import 'package:attendance_system_hris/screens/attendance/attendance_screen.dart';
import 'package:attendance_system_hris/screens/attendance/check_in_screen.dart';
import 'package:attendance_system_hris/screens/attendance/check_out_screen.dart';
import 'package:attendance_system_hris/screens/attendance/attendance_request_screen.dart';
import 'package:attendance_system_hris/screens/attendance/attendance_list_screen.dart';
import 'package:attendance_system_hris/screens/leave/leave_screen.dart';
import 'package:attendance_system_hris/screens/leave/request_leave_screen.dart';
import 'package:attendance_system_hris/screens/leave/view_leave_requests_screen.dart';
import 'package:attendance_system_hris/screens/report/report_screen.dart';
import 'package:attendance_system_hris/screens/settings/settings_screen.dart';
import 'package:attendance_system_hris/screens/settings/change_password_screen.dart';
import 'package:attendance_system_hris/screens/settings/profile_screen.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String quickAttendance = '/quick-attendance';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String attendance = '/attendance';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String attendanceRequest = '/attendance/request';
  static const String attendanceList = '/attendance/list';
  static const String leave = '/leave';
  static const String requestLeave = '/leave/request';
  static const String leaveList = '/leave/list';
  static const String report = '/report';
  static const String settings = '/settings';
  static const String changePassword = '/settings/change-password';
  static const String profile = '/settings/profile';

  // Route generation
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: routeSettings,
        );
      
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: routeSettings,
        );
      
      case quickAttendance:
        return MaterialPageRoute(
          builder: (_) => const QuickAttendanceScreen(),
          settings: routeSettings,
        );
      
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: routeSettings,
        );
      
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: routeSettings,
        );
      
      case attendance:
        return MaterialPageRoute(
          builder: (_) => const AttendanceScreen(),
          settings: routeSettings,
        );
      
      case checkIn:
        return MaterialPageRoute(
          builder: (_) => const CheckInScreen(),
          settings: routeSettings,
        );
      
      case checkOut:
        return MaterialPageRoute(
          builder: (_) => const CheckOutScreen(),
          settings: routeSettings,
        );
      
      case attendanceRequest:
        return MaterialPageRoute(
          builder: (_) => const AttendanceRequestScreen(),
          settings: routeSettings,
        );
      
      case attendanceList:
        return MaterialPageRoute(
          builder: (_) => const AttendanceListScreen(),
          settings: routeSettings,
        );
      
      case leave:
        return MaterialPageRoute(
          builder: (_) => const LeaveScreen(),
          settings: routeSettings,
        );
      
      case requestLeave:
        return MaterialPageRoute(
          builder: (_) => const RequestLeaveScreen(),
          settings: routeSettings,
        );
      
      case leaveList:
        return MaterialPageRoute(
          builder: (_) => const ViewLeaveRequestsScreen(),
          settings: routeSettings,
        );
      
      case report:
        return MaterialPageRoute(
          builder: (_) => const ReportScreen(),
          settings: routeSettings,
        );
      
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );
      
      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: routeSettings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: routeSettings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation methods
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateToAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  static void navigateToAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
} 