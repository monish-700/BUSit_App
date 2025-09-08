import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/credential_input_widget.dart';
import './widgets/social_login_widget.dart';
import './widgets/transport_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ScrollController _scrollController = ScrollController();
  String _emailPhone = '';
  String _password = '';
  bool _isEmailMode = true;
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  String _errorMessage = '';

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'commuter@busit.com': {'password': 'commuter123', 'type': 'Daily Commuter'},
    'tourist@busit.com': {'password': 'tourist123', 'type': 'Tourist'},
    'senior@busit.com': {'password': 'senior123', 'type': 'Senior Citizen'},
    '+919876543210': {'password': 'mobile123', 'type': 'Mobile User'},
    '+919123456789': {'password': 'driver123', 'type': 'Bus Driver'},
  };

  bool get _isFormValid => _emailPhone.isNotEmpty && _password.length >= 6;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleEmailPhoneChanged(String value) {
    setState(() {
      _emailPhone = value;
      _errorMessage = '';
    });
  }

  void _handlePasswordChanged(String value) {
    setState(() {
      _password = value;
      _errorMessage = '';
    });
  }

  void _handleModeChanged(bool isEmailMode) {
    setState(() {
      _isEmailMode = isEmailMode;
      _emailPhone = '';
      _password = '';
      _errorMessage = '';
    });
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Check mock credentials
    final credentials = _mockCredentials[_emailPhone];
    if (credentials != null && credentials['password'] == _password) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      setState(() {
        _isLoading = false;
        _showBiometricPrompt = true;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = _isEmailMode
            ? 'Invalid email or password. Please check your credentials and try again.'
            : 'Invalid mobile number or password. Please verify your details.';
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _handleBiometricLogin() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/live-bus-map');
  }

  void _handleSkipBiometric() {
    Navigator.pushReplacementNamed(context, '/live-bus-map');
  }

  void _handleForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            CustomIconWidget(
              iconName: 'lock_reset',
              color: AppTheme.lightTheme.primaryColor,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Reset Password',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Enter your email or phone number to receive password reset instructions',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 3.h),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter email or phone number',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('Password reset link sent successfully!'),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );
                },
                child: const Text('Send Reset Link'),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/live-bus-map');
  }

  void _handleAppleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/live-bus-map');
  }

  void _handleSignUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
            'Sign up feature will be available soon. Please use the provided demo credentials to explore the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // Transport Logo
                    const TransportLogoWidget(),
                    SizedBox(height: 6.h),

                    // Welcome Text
                    Text(
                      'Welcome to BUSit',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Your smart companion for public transportation',
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Credential Input
                    CredentialInputWidget(
                      onEmailPhoneChanged: _handleEmailPhoneChanged,
                      onPasswordChanged: _handlePasswordChanged,
                      onForgotPassword: _handleForgotPassword,
                      isEmailMode: _isEmailMode,
                      onModeChanged: _handleModeChanged,
                    ),
                    SizedBox(height: 4.h),

                    // Error Message
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isFormValid && !_isLoading ? _handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          backgroundColor: _isFormValid
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.12),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Login',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Social Login
                    SocialLoginWidget(
                      onGoogleLogin: _handleGoogleLogin,
                      onAppleLogin: _handleAppleLogin,
                    ),
                    SizedBox(height: 6.h),

                    // Sign Up Link
                    GestureDetector(
                      onTap: _handleSignUp,
                      child: RichText(
                        text: TextSpan(
                          text: 'New to public transport? ',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Biometric Prompt Overlay
            if (_showBiometricPrompt)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: BiometricPromptWidget(
                    onBiometricLogin: _handleBiometricLogin,
                    onSkip: _handleSkipBiometric,
                    isVisible: _showBiometricPrompt,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
