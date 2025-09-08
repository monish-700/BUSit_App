import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class VoiceSettingsPanel extends StatelessWidget {
  final double speechRate;
  final double pitch;
  final String voiceGender;
  final Function(double) onSpeechRateChanged;
  final Function(double) onPitchChanged;
  final Function(String) onVoiceGenderChanged;

  const VoiceSettingsPanel({
    Key? key,
    required this.speechRate,
    required this.pitch,
    required this.voiceGender,
    required this.onSpeechRateChanged,
    required this.onPitchChanged,
    required this.onVoiceGenderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(4.w),
        ),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'settings_voice',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Voice Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Speech Rate
          Text(
            'Speech Rate',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'speed',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Slider(
                  value: speechRate,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: onSpeechRateChanged,
                ),
              ),
              Text(
                '${speechRate.toStringAsFixed(1)}x',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Pitch
          Text(
            'Voice Pitch',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'tune',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Slider(
                  value: pitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: onPitchChanged,
                ),
              ),
              Text(
                pitch.toStringAsFixed(1),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Voice Gender
          Text(
            'Voice Gender',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onVoiceGenderChanged('male'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: voiceGender == 'male'
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: voiceGender == 'male'
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'man',
                          color: voiceGender == 'male'
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Male',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: voiceGender == 'male'
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onVoiceGenderChanged('female'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: voiceGender == 'female'
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: voiceGender == 'female'
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'woman',
                          color: voiceGender == 'female'
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Female',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: voiceGender == 'female'
                                ? Colors.white
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
