import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_input.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/api/auth_api_service.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';
import 'package:dio/dio.dart';

class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({super.key});

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRedirecting = false;
  String _selectedAction = 'CHECKIN';

  final List<String> _actions = ['CHECKIN', 'CHECKOUT'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleQuickAttendance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('⚡ QuickAttendanceScreen: Starting quick attendance process');
      print('⚡ QuickAttendanceScreen: Email: ${_emailController.text.trim()}');
      print('⚡ QuickAttendanceScreen: Action: $_selectedAction');
      
      final request = QuickAttendanceRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        action: _selectedAction,
      );

      final response = await AuthApiService.quickAttendance(request);

      print('⚡ QuickAttendanceScreen: Quick attendance result: ${response.code}');

      if (mounted) {
        if (response.isSuccess) {
          print('✅ QuickAttendanceScreen: Quick attendance successful');
          _showSuccessSnackBar('${response.message}');
          
          // Set redirecting state
          setState(() {
            _isRedirecting = true;
          });
          
          // Clear form after successful submission
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            _selectedAction = 'CHECKIN';
          });
          
          // Redirect to login page after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              AppRouter.navigateToAndRemoveUntil(context, AppRouter.login);
            }
          });
        } else {
          print('❌ QuickAttendanceScreen: Quick attendance failed');
          _showErrorSnackBar(response.message);
        }
      }
    } on ApiError catch (e) {
      print('❌ QuickAttendanceScreen: ApiError caught: ${e.displayMessage}');
      if (mounted) {
        _showErrorSnackBar(e.displayMessage);
      }
    } on DioException catch (e) {
      print('❌ QuickAttendanceScreen: DioException caught: ${e.type}');
      print('❌ QuickAttendanceScreen: DioException message: ${e.message}');
      if (mounted) {
        String errorMessage = 'Connection error';
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timeout. Please check your internet connection.';
            break;
          case DioExceptionType.connectionError:
            errorMessage = 'No internet connection. Please check your network.';
            break;
          case DioExceptionType.badResponse:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage = 'Quick attendance failed. Please try again.';
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('❌ QuickAttendanceScreen: General exception caught: ${e.toString()}');
      print('❌ QuickAttendanceScreen: Exception type: ${e.runtimeType}');
      if (mounted) {
        _showErrorSnackBar('Quick attendance failed. Please check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Quick Attendance'),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Quick Attendance',
                        style: AppTheme.headingLarge.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mark your attendance quickly',
                        style: AppTheme.bodyLarge.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isRedirecting) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Redirecting to login page...',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Quick Attendance Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppInput(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        AppInput(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          validator: _validatePassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          onSubmitted: (_) => _handleQuickAttendance(),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Action',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedAction,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: _actions.map((String action) {
                                  return DropdownMenuItem<String>(
                                    value: action,
                                    child: Row(
                                      children: [
                                        Icon(
                                          action == 'CHECKIN' ? Icons.login : Icons.logout,
                                          color: action == 'CHECKIN' ? AppTheme.successColor : AppTheme.warningColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          action == 'CHECKIN' ? 'Check In' : 'Check Out',
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedAction = newValue;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select an action';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        AppButton(
                          text: _isRedirecting ? 'Redirecting...' : 'Mark Attendance',
                          onPressed: _isRedirecting ? null : _handleQuickAttendance,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          icon: _selectedAction == 'CHECKIN' ? Icons.login : Icons.logout,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Footer
                  Text(
                    'Quick attendance allows you to mark your attendance without full login',
                    style: AppTheme.bodySmall.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 