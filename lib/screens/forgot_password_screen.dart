import 'package:flutter/material.dart';
import 'package:attendance_system_hris/components/common/app_button.dart';
import 'package:attendance_system_hris/components/common/app_input.dart';
import 'package:attendance_system_hris/core/theme/app_theme.dart';
import 'package:attendance_system_hris/core/routes/app_router.dart';
import 'package:attendance_system_hris/services/api/auth_api_service.dart';
import 'package:attendance_system_hris/models/api/auth_models.dart';
import 'package:dio/dio.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _otpSent = false;
  bool _isRedirecting = false;
  String _currentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 ForgotPasswordScreen: Sending OTP request');
      print('🔐 ForgotPasswordScreen: Email: ${_emailController.text.trim()}');
      
      final response = await AuthApiService.forgotPassword(_emailController.text.trim());

      print('🔐 ForgotPasswordScreen: OTP response: ${response.code}');

      if (mounted) {
        if (response.isSuccess) {
          print('✅ ForgotPasswordScreen: OTP sent successfully');
          _showSuccessSnackBar(response.message);
          setState(() {
            _otpSent = true;
            _currentEmail = _emailController.text.trim();
          });
        } else {
          print('❌ ForgotPasswordScreen: Failed to send OTP');
          _showErrorSnackBar(response.message);
        }
      }
    } on ApiError catch (e) {
      print('❌ ForgotPasswordScreen: ApiError caught: ${e.displayMessage}');
      if (mounted) {
        _showErrorSnackBar(e.displayMessage);
      }
    } on DioException catch (e) {
      print('❌ ForgotPasswordScreen: DioException caught: ${e.type}');
      print('❌ ForgotPasswordScreen: DioException message: ${e.message}');
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
            errorMessage = 'Failed to send OTP. Please try again.';
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('❌ ForgotPasswordScreen: General exception caught: ${e.toString()}');
      print('❌ ForgotPasswordScreen: Exception type: ${e.runtimeType}');
      if (mounted) {
        _showErrorSnackBar('Failed to send OTP. Please check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 ForgotPasswordScreen: Verifying OTP');
      print('🔐 ForgotPasswordScreen: Email: $_currentEmail');
      print('🔐 ForgotPasswordScreen: OTP: ${_otpController.text}');
      
      final otpNumber = int.tryParse(_otpController.text);
      if (otpNumber == null || otpNumber <= 0) {
        _showErrorSnackBar('Please enter a valid OTP');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final request = VerifyOtpRequest(
        email: _currentEmail,
        otp: otpNumber,
        password: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      print('🔐 ForgotPasswordScreen: Request data: ${request.toJson()}');

      final response = await AuthApiService.verifyOtp(request);

      print('🔐 ForgotPasswordScreen: Verify OTP response: ${response.code}');

      if (mounted) {
        if (response.isSuccess) {
          print('✅ ForgotPasswordScreen: Password updated successfully');
          _showSuccessSnackBar('${response.message}\nRedirecting to login page...');
          
          // Set redirecting state
          setState(() {
            _isRedirecting = true;
          });
          
          // Redirect to login page after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              AppRouter.navigateToAndRemoveUntil(context, AppRouter.login);
            }
          });
        } else {
          print('❌ ForgotPasswordScreen: Failed to verify OTP');
          _showErrorSnackBar(response.message);
        }
      }
    } on ApiError catch (e) {
      print('❌ ForgotPasswordScreen: ApiError caught: ${e.displayMessage}');
      if (mounted) {
        _showErrorSnackBar(e.displayMessage);
      }
    } on DioException catch (e) {
      print('❌ ForgotPasswordScreen: DioException caught: ${e.type}');
      print('❌ ForgotPasswordScreen: DioException message: ${e.message}');
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
            errorMessage = 'Failed to verify OTP. Please try again.';
        }
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      print('❌ ForgotPasswordScreen: General exception caught: ${e.toString()}');
      print('❌ ForgotPasswordScreen: Exception type: ${e.runtimeType}');
      if (mounted) {
        _showErrorSnackBar('Failed to verify OTP. Please check your connection and try again.');
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

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length < 4) {
      return 'OTP must be at least 4 characters';
    }
    final otpNumber = int.tryParse(value);
    if (otpNumber == null) {
      return 'OTP must be a valid number';
    }
    if (otpNumber <= 0) {
      return 'OTP must be a valid positive number';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
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
        title: const Text('Forgot Password'),
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
                          Icons.lock_reset,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Forgot Password',
                        style: AppTheme.headingLarge.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent 
                            ? 'Enter the OTP sent to your email and set a new password'
                            : 'Enter your email to receive a password reset OTP',
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
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_otpSent) ...[
                          // Email Input
                          AppInput(
                            label: 'Email',
                            hint: 'Enter your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocusNode,
                            textInputAction: TextInputAction.done,
                            validator: _validateEmail,
                            prefixIcon: const Icon(Icons.email_outlined),
                            onSubmitted: (_) => _handleSendOtp(),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Send OTP Button
                          AppButton(
                            text: 'Send OTP',
                            onPressed: _handleSendOtp,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            icon: Icons.send,
                          ),
                        ] else ...[
                          // OTP Input
                          AppInput(
                            label: 'OTP',
                            hint: 'Enter the OTP sent to your email',
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            focusNode: _otpFocusNode,
                            textInputAction: TextInputAction.next,
                            validator: _validateOtp,
                            prefixIcon: const Icon(Icons.security),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // New Password Input
                          AppInput(
                            label: 'New Password',
                            hint: 'Enter your new password',
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            focusNode: _newPasswordFocusNode,
                            textInputAction: TextInputAction.next,
                            validator: _validateNewPassword,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Confirm Password Input
                          AppInput(
                            label: 'Confirm Password',
                            hint: 'Confirm your new password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            focusNode: _confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            validator: _validateConfirmPassword,
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            onSubmitted: (_) => _handleVerifyOtp(),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Verify OTP Button
                          AppButton(
                            text: _isRedirecting ? 'Redirecting...' : 'Reset Password',
                            onPressed: _isRedirecting ? null : _handleVerifyOtp,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            icon: Icons.check_circle,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Back to Email Button
                          AppButton(
                            text: 'Back to Email',
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                                _currentEmail = '';
                              });
                            },
                            isFullWidth: true,
                            icon: Icons.arrow_back,
                            variant: ButtonVariant.outline,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Footer
                  Text(
                    'We\'ll send you a one-time password to reset your password',
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