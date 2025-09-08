import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CredentialInputWidget extends StatefulWidget {
  final Function(String) onEmailPhoneChanged;
  final Function(String) onPasswordChanged;
  final VoidCallback onForgotPassword;
  final bool isEmailMode;
  final Function(bool) onModeChanged;

  const CredentialInputWidget({
    super.key,
    required this.onEmailPhoneChanged,
    required this.onPasswordChanged,
    required this.onForgotPassword,
    required this.isEmailMode,
    required this.onModeChanged,
  });

  @override
  State<CredentialInputWidget> createState() => _CredentialInputWidgetState();
}

class _CredentialInputWidgetState extends State<CredentialInputWidget> {
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _selectedCountryCode = '+91';
  String _emailPhoneError = '';
  String _passwordError = '';

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmailPhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailPhoneError = widget.isEmailMode
            ? 'Email is required'
            : 'Phone number is required';
      } else if (widget.isEmailMode) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        _emailPhoneError = emailRegex.hasMatch(value)
            ? ''
            : 'Please enter a valid email address';
      } else {
        final phoneRegex = RegExp(r'^[6-9]\d{9}$');
        _emailPhoneError = phoneRegex.hasMatch(value)
            ? ''
            : 'Please enter a valid 10-digit mobile number';
      }
    });
    widget.onEmailPhoneChanged(
        widget.isEmailMode ? value : '$_selectedCountryCode$value');
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = '';
      }
    });
    widget.onPasswordChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode Toggle
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onModeChanged(true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: widget.isEmailMode
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Email',
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: widget.isEmailMode
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: widget.isEmailMode
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onModeChanged(false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: !widget.isEmailMode
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Phone',
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: !widget.isEmailMode
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: !widget.isEmailMode
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3.h),

        // Email/Phone Input
        Text(
          widget.isEmailMode ? 'Email Address' : 'Mobile Number',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _emailPhoneError.isNotEmpty
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              if (!widget.isEmailMode) ...[
                CountryCodePicker(
                  onChanged: (country) {
                    setState(() {
                      _selectedCountryCode = country.dialCode!;
                    });
                    _validateEmailPhone(_emailPhoneController.text);
                  },
                  initialSelection: 'IN',
                  favorite: const ['+91', 'IN'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  textStyle: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: _emailPhoneController,
                  keyboardType: widget.isEmailMode
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  inputFormatters: widget.isEmailMode
                      ? null
                      : [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                  onChanged: _validateEmailPhone,
                  decoration: InputDecoration(
                    hintText: widget.isEmailMode
                        ? 'Enter your email'
                        : 'Enter 10-digit number',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    prefixIcon: CustomIconWidget(
                      iconName: widget.isEmailMode ? 'email' : 'phone',
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        if (_emailPhoneError.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(
            _emailPhoneError,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 3.h),

        // Password Input
        Text(
          'Password',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          onChanged: _validatePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 20,
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: CustomIconWidget(
                iconName: _isPasswordVisible ? 'visibility' : 'visibility_off',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _passwordError.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _passwordError.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _passwordError.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        if (_passwordError.isNotEmpty) ...[
          SizedBox(height: 0.5.h),
          Text(
            _passwordError,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 2.h),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: widget.onForgotPassword,
            child: Text(
              'Forgot Password?',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
