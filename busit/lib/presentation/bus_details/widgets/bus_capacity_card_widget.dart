import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BusCapacityCardWidget extends StatelessWidget {
  final Map<String, dynamic> busData;
  final bool isSelected;
  final VoidCallback onTap;

  const BusCapacityCardWidget({
    Key? key,
    required this.busData,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capacity = busData['capacity'] as String;
    final eta = busData['eta'] as String;
    final busNumber = busData['busNumber'] as String;
    final hasWifi = busData['hasWifi'] as bool? ?? false;
    final hasAC = busData['hasAC'] as bool? ?? false;
    final isAccessible = busData['isAccessible'] as bool? ?? false;

    Color capacityColor = _getCapacityColor(capacity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bus number and ETA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    busNumber,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  eta,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Capacity indicator
            Row(
              children: [
                Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: capacityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  _getCapacityText(capacity),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Capacity bar
            Container(
              height: 0.8.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getCapacityPercentage(capacity),
                child: Container(
                  decoration: BoxDecoration(
                    color: capacityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Accessibility features
            Row(
              children: [
                if (hasWifi) _buildFeatureIcon('wifi', 'WiFi Available'),
                if (hasAC) _buildFeatureIcon('ac_unit', 'Air Conditioned'),
                if (isAccessible)
                  _buildFeatureIcon('accessible', 'Wheelchair Accessible'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(String iconName, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 16,
        ),
      ),
    );
  }

  Color _getCapacityColor(String capacity) {
    switch (capacity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getCapacityText(String capacity) {
    switch (capacity.toLowerCase()) {
      case 'low':
        return 'Plenty of seats';
      case 'medium':
        return 'Some seats available';
      case 'high':
        return 'Standing room only';
      default:
        return 'Unknown capacity';
    }
  }

  double _getCapacityPercentage(String capacity) {
    switch (capacity.toLowerCase()) {
      case 'low':
        return 0.3;
      case 'medium':
        return 0.7;
      case 'high':
        return 0.95;
      default:
        return 0.5;
    }
  }
}
