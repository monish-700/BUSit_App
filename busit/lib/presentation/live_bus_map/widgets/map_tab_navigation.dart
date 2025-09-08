import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapTabNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const MapTabNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<MapTabNavigation> createState() => _MapTabNavigationState();
}

class _MapTabNavigationState extends State<MapTabNavigation>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': 'map',
      'label': 'Map',
      'route': '/live-bus-map',
    },
    {
      'icon': 'directions_bus',
      'label': 'Bus Details',
      'route': '/bus-details',
    },
    {
      'icon': 'mic',
      'label': 'Voice',
      'route': '/voice-assistant',
    },
    {
      'icon': 'search',
      'label': 'Search',
      'route': '/route-search',
    },
    {
      'icon': 'settings',
      'label': 'Settings',
      'route': '/settings',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToTab(int index) {
    if (index != widget.currentIndex) {
      final route = _tabs[index]['route'] as String;
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: TabBar(
          controller: _tabController,
          tabs: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = index == widget.currentIndex;

            return Tab(
              height: 8.h,
              child: GestureDetector(
                onTap: () => _navigateToTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: tab['icon'] as String,
                          color: isActive
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          size: 5.w,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        tab['label'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          indicator: const BoxDecoration(),
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          onTap: _navigateToTab,
        ),
      ),
    );
  }
}
