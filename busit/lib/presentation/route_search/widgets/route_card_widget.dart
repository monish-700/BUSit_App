import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteCardWidget extends StatelessWidget {
  final Map<String, dynamic> routeData;
  final VoidCallback onTap;
  final bool isSelected;

  const RouteCardWidget({
    Key? key,
    required this.routeData,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primaryContainer
                : AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'directions_bus',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            routeData["routeName"] as String,
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(routeData["status"] as String),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      routeData["status"] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  _buildInfoItem(
                    icon: 'schedule',
                    label: routeData["duration"] as String,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 4.w),
                  _buildInfoItem(
                    icon: 'transfer_within_a_station',
                    label: "${routeData["transfers"]} transfers",
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _buildInfoItem(
                    icon: 'directions_walk',
                    label: routeData["walkingDistance"] as String,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 4.w),
                  _buildInfoItem(
                    icon: 'currency_rupee',
                    label: routeData["fare"] as String,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                routeData["description"] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 16,
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'delayed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }
}
