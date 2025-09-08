import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationSwapWidget extends StatelessWidget {
  final VoidCallback onSwap;

  const LocationSwapWidget({
    Key? key,
    required this.onSwap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.0,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            child: GestureDetector(
              onTap: onSwap,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: CustomIconWidget(
                  iconName: 'swap_vert',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.0,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
