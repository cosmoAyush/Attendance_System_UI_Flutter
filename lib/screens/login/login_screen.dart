import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_input.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/auth_service.dart';
import 'package:attendance_system_hris/services/biometric_service.dart';
import 'package:attendance_system_hris/services/biometric_auth_helper.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String? _savedEmail;
  String? _biometricTypeName;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await BiometricAuthHelper.isBiometricEnabled();
      final savedEmail = await BiometricAuthHelper.getSavedEmail();
      final biometricType = await BiometricAuthHelper.getCurrentBiometricType();

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isBiometricEnabled = isEnabled;
          _savedEmail = savedEmail;
          _biometricTypeName = biometricType;
        });
      }

      print('🔐 LoginScreen: Biometric available: $isAvailable');
      print('🔐 LoginScreen: Biometric enabled: $isEnabled');
      print('🔐 LoginScreen: Saved email: $savedEmail');
      print('🔐 LoginScreen: Biometric type: $biometricType');
    } catch (e) {
      print('❌ LoginScreen: Error checking biometric availability: $e');
      // Set biometric as not available if there's an error
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isBiometricEnabled = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 LoginScreen: Starting login process');
      print('🔐 LoginScreen: Email: ${_emailController.text.trim()}');
      
      final success = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('🔐 LoginScreen: Login result: $success');

      if (success && mounted) {
        print('✅ LoginScreen: Login successful, navigating to dashboard');
        _showSuccessSnackBar('Login successful!');
        
        // Offer to enable biometric authentication if available and not enabled
        if (_isBiometricAvailable && !_isBiometricEnabled) {
          _showBiometricEnableDialog();
        } else {
          AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
        }
      } else if (mounted) {
        print('❌ LoginScreen: Login failed - invalid credentials');
        _showErrorSnackBar('Invalid email or password');
      }
    } on ApiError catch (e) {
      print('❌ LoginScreen: ApiError caught: ${e.displayMessage}');
      if (mounted) {
        _showErrorSnackBar(e.displayMessage);
      }
    } on DioException catch (e) {
      print('❌ LoginScreen: DioException caught: ${e.type}');
      print('❌ LoginScreen: DioException message: ${e.message}');
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
            errorMessage = 'Login failed. Please try again.';
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('❌ LoginScreen: General exception caught: ${e.toString()}');
      print('❌ LoginScreen: Exception type: ${e.runtimeType}');
      if (mounted) {
        _showErrorSnackBar('Login failed. Please check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 LoginScreen: Starting biometric login');
      
      final success = await BiometricAuthHelper.authenticateWithBiometrics();

      if (mounted) {
        if (success) {
          print('✅ LoginScreen: Biometric login successful');
          _showSuccessSnackBar('Login successful!');
          AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
        } else {
          print('❌ LoginScreen: Biometric login failed');
          _showErrorSnackBar('Biometric authentication failed');
        }
      }
    } catch (e) {
      print('❌ LoginScreen: Error during biometric login: $e');
      if (mounted) {
        _showErrorSnackBar('Biometric authentication failed');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showBiometricEnableDialog() {
    final biometricType = _biometricTypeName ?? 'Biometric';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable $biometricType Login'),
          content: Text(
            'Would you like to enable $biometricType login for faster access?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
              },
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _enableBiometric();
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _enableBiometric() async {
    try {
      final success = await BiometricAuthHelper.enableBiometric(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Biometric login enabled!');
          await _checkBiometricAvailability();
        } else {
          _showErrorSnackBar('Failed to enable biometric login');
        }
        AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
      }
    } catch (e) {
      print('❌ LoginScreen: Error enabling biometric: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to enable biometric login');
        AppRouter.navigateToAndRemoveUntil(context, AppRouter.dashboard);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
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
                          Icons.work,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        style: AppTheme.headingLarge.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: AppTheme.bodyLarge.copyWith(
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Login Form
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
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        AppButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          icon: Icons.login,
                        ),
                        
                        // Biometric Login Button - Show when biometric is enabled
                        if (_isBiometricAvailable && _isBiometricEnabled) ...[
                          const SizedBox(height: 16),
                          
                          AppButton(
                            text: 'Login with ${_biometricTypeName ?? 'Biometric'}',
                            onPressed: _handleBiometricLogin,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            icon: Icons.fingerprint,
                            variant: ButtonVariant.outline,
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Divider with "or" text
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.onBackground.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.onBackground.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick Attendance Button
                        AppButton(
                          text: 'Quick Attendance',
                          onPressed: () {
                            AppRouter.navigateTo(context, AppRouter.quickAttendance);
                          },
                          isFullWidth: true,
                          icon: Icons.access_time,
                          variant: ButtonVariant.outline,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      AppRouter.navigateTo(context, AppRouter.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  // Biometric Settings Section - Show when biometric is enabled
                  if (_isBiometricAvailable && _isBiometricEnabled) ...[
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Biometric Login Enabled',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Logged in as: ${_savedEmail ?? 'Unknown'}',
                            style: AppTheme.bodySmall.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          TextButton(
                            onPressed: () async {
                              final success = await BiometricAuthHelper.disableBiometric();
                              if (mounted) {
                                if (success) {
                                  _showSuccessSnackBar('Biometric login disabled');
                                  await _checkBiometricAvailability();
                                } else {
                                  _showErrorSnackBar('Failed to disable biometric login');
                                }
                              }
                            },
                            child: Text(
                              'Disable Biometric Login',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Footer
                  Text(
                    '© 2024 Employee Attendance System',
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