import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> stops;
  final int currentBusStopIndex;
  final int userBoardingStopIndex;
  final int userAlightingStopIndex;

  const RouteTimelineWidget({
    Key? key,
    required this.stops,
    required this.currentBusStopIndex,
    required this.userBoardingStopIndex,
    required this.userAlightingStopIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route Timeline',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 35.h,
            child: ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final isCurrentBusStop = index == currentBusStopIndex;
                final isUserBoardingStop = index == userBoardingStopIndex;
                final isUserAlightingStop = index == userAlightingStopIndex;
                final isPassed = index < currentBusStopIndex;

                return _buildTimelineItem(
                  context,
                  stop,
                  index,
                  isCurrentBusStop,
                  isUserBoardingStop,
                  isUserAlightingStop,
                  isPassed,
                  index == stops.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> stop,
    int index,
    bool isCurrentBusStop,
    bool isUserBoardingStop,
    bool isUserAlightingStop,
    bool isPassed,
    bool isLast,
  ) {
    Color dotColor = AppTheme.lightTheme.colorScheme.outline;
    Color lineColor = AppTheme.lightTheme.colorScheme.outline;

    if (isPassed) {
      dotColor = AppTheme.lightTheme.colorScheme.primary;
      lineColor = AppTheme.lightTheme.colorScheme.primary;
    } else if (isCurrentBusStop) {
      dotColor = AppTheme.lightTheme.colorScheme.tertiary;
    }

    if (isUserBoardingStop || isUserAlightingStop) {
      dotColor = AppTheme.lightTheme.colorScheme.secondary;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrentBusStop
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isCurrentBusStop
                    ? CustomIconWidget(
                        iconName: 'directions_bus',
                        color: Colors.white,
                        size: 2.w,
                      )
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 0.5.w,
                  height: 8.h,
                  color: lineColor.withValues(alpha: 0.3),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          // Stop information
          Expanded(
            child: GestureDetector(
              onLongPress: () => _showStopOptions(context, stop),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            stop['name'] as String,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: isCurrentBusStop ||
                                      isUserBoardingStop ||
                                      isUserAlightingStop
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isPassed
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          stop['eta'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isCurrentBusStop
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (isUserBoardingStop || isUserAlightingStop)
                      Container(
                        margin: EdgeInsets.only(top: 0.5.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isUserBoardingStop
                              ? 'Boarding Stop'
                              : 'Alighting Stop',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isCurrentBusStop)
                      Container(
                        margin: EdgeInsets.only(top: 0.5.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Bus Currently Here',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStopOptions(BuildContext context, Map<String, dynamic> stop) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stop['name'] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Set as Favorite'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'directions_walk',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Get Walking Directions'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('View Stop Details'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
