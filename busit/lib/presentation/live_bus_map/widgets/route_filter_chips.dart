import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RouteFilterChips extends StatefulWidget {
  final Function(List<String>) onFiltersChanged;

  const RouteFilterChips({
    Key? key,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<RouteFilterChips> createState() => _RouteFilterChipsState();
}

class _RouteFilterChipsState extends State<RouteFilterChips> {
  final List<Map<String, dynamic>> _availableRoutes = [
    {'name': 'Route 45', 'count': 3, 'color': Colors.blue},
    {'name': 'Route 12', 'count': 2, 'color': Colors.green},
    {'name': 'Route 23', 'count': 4, 'color': Colors.orange},
    {'name': 'Route 67', 'count': 1, 'color': Colors.purple},
    {'name': 'Route 89', 'count': 2, 'color': Colors.red},
    {'name': 'Route 34', 'count': 3, 'color': Colors.teal},
  ];

  List<String> _selectedRoutes = [];

  void _toggleRoute(String routeName) {
    setState(() {
      if (_selectedRoutes.contains(routeName)) {
        _selectedRoutes.remove(routeName);
      } else {
        _selectedRoutes.add(routeName);
      }
    });
    widget.onFiltersChanged(_selectedRoutes);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedRoutes.clear();
    });
    widget.onFiltersChanged(_selectedRoutes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _selectedRoutes.isNotEmpty ? 12.h : 8.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _availableRoutes.length,
              itemBuilder: (context, index) {
                final route = _availableRoutes[index];
                final routeName = route['name'] as String;
                final count = route['count'] as int;
                final color = route['color'] as Color;
                final isSelected = _selectedRoutes.contains(routeName);

                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    selected: isSelected,
                    onSelected: (selected) => _toggleRoute(routeName),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          routeName,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.onPrimary
                                    .withValues(alpha: 0.2)
                                : AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            count.toString(),
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                    selectedColor: AppTheme.lightTheme.colorScheme.primary,
                    checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedRoutes.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Text(
                    '${_selectedRoutes.length} route${_selectedRoutes.length > 1 ? 's' : ''} selected',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      minimumSize: Size(0, 0),
                    ),
                    child: Text(
                      'Clear all',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
