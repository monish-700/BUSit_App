import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelectorWidget({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> languages = [
      {"code": "en", "name": "English", "nativeName": "English"},
      {"code": "hi", "name": "Hindi", "nativeName": "हिंदी"},
      {"code": "pa", "name": "Punjabi", "nativeName": "ਪੰਜਾਬੀ"},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'language',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Language",
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Select your preferred language",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: selectedLanguage,
            onSelected: onLanguageChanged,
            itemBuilder: (context) => languages.map((language) {
              return PopupMenuItem<String>(
                value: language["code"]!,
                child: Row(
                  children: [
                    Text(
                      language["nativeName"]!,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "(${language["name"]!})",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    if (selectedLanguage == language["code"]!) ...[
                      Spacer(),
                      CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 4.w,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languages.firstWhere(
                      (lang) => lang["code"] == selectedLanguage,
                      orElse: () => languages.first,
                    )["nativeName"]!,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
