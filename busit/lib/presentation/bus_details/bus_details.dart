import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bus_capacity_card_widget.dart';
import './widgets/route_info_card_widget.dart';
import './widgets/route_timeline_widget.dart';
import './widgets/sticky_header_widget.dart';

class BusDetails extends StatefulWidget {
  @override
  _BusDetailsState createState() => _BusDetailsState();
}

class _BusDetailsState extends State<BusDetails> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _refreshController;
  int _selectedBusIndex = 0;
  bool _isRefreshing = false;

  // Mock data for bus route
  final Map<String, dynamic> routeData = {
    "routeNumber": "42A",
    "origin": "Central Station",
    "destination": "Airport Terminal",
    "direction": "Northbound",
    "status": "On Time",
    "currentBusStopIndex": 3,
    "userBoardingStopIndex": 5,
    "userAlightingStopIndex": 8,
  };

  final List<Map<String, dynamic>> busStops = [
    {"name": "Central Station", "eta": "Departed"},
    {"name": "City Mall", "eta": "Departed"},
    {"name": "University Campus", "eta": "Departed"},
    {"name": "Hospital Junction", "eta": "Now"},
    {"name": "Tech Park", "eta": "3 min"},
    {"name": "Metro Station", "eta": "8 min"},
    {"name": "Shopping Complex", "eta": "12 min"},
    {"name": "Business District", "eta": "18 min"},
    {"name": "Convention Center", "eta": "22 min"},
    {"name": "Airport Terminal", "eta": "28 min"},
  ];

  final List<Map<String, dynamic>> busesOnRoute = [
    {
      "busNumber": "KA-01-AB-1234",
      "eta": "8 min",
      "capacity": "low",
      "hasWifi": true,
      "hasAC": true,
      "isAccessible": true,
    },
    {
      "busNumber": "KA-01-AB-5678",
      "eta": "15 min",
      "capacity": "medium",
      "hasWifi": false,
      "hasAC": true,
      "isAccessible": false,
    },
    {
      "busNumber": "KA-01-AB-9012",
      "eta": "22 min",
      "capacity": "high",
      "hasWifi": true,
      "hasAC": false,
      "isAccessible": true,
    },
  ];

  final List<Map<String, dynamic>> fareInfo = [
    {"label": "Base Fare", "value": "₹15", "icon": "currency_rupee"},
    {"label": "Distance", "value": "12.5 km", "icon": "straighten"},
    {"label": "Journey Time", "value": "28 minutes", "icon": "schedule"},
    {
      "label": "Payment Methods",
      "value": "UPI, Card, Wallet",
      "icon": "payment"
    },
  ];

  final List<Map<String, dynamic>> scheduleInfo = [
    {"label": "First Bus", "value": "5:30 AM", "icon": "wb_sunny"},
    {"label": "Last Bus", "value": "11:45 PM", "icon": "nights_stay"},
    {"label": "Frequency", "value": "Every 8-12 minutes", "icon": "schedule"},
    {
      "label": "Service Days",
      "value": "Monday to Sunday",
      "icon": "calendar_today"
    },
  ];

  final List<Map<String, dynamic>> accessibilityInfo = [
    {
      "label": "Wheelchair Access",
      "value": "Available on select buses",
      "icon": "accessible"
    },
    {
      "label": "Audio Announcements",
      "value": "English, Hindi, Kannada",
      "icon": "volume_up"
    },
    {
      "label": "Priority Seating",
      "value": "4 seats per bus",
      "icon": "airline_seat_recline_extra"
    },
    {
      "label": "Low Floor Entry",
      "value": "All buses equipped",
      "icon": "stairs"
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refreshController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _refreshController.forward();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    _refreshController.reverse();
    setState(() => _isRefreshing = false);
  }

  void _showMoreOptions() {
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
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'More Options',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildBottomSheetOption('notifications', 'Set Reminder',
                'Get notified before bus arrival'),
            _buildBottomSheetOption(
                'share', 'Share Route', 'Share route details with others'),
            _buildBottomSheetOption('report_problem', 'Report Issue',
                'Report problems with this route'),
            _buildBottomSheetOption('alt_route', 'Alternative Routes',
                'Find other routes to destination'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
      String iconName, String title, String subtitle) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  void _trackBus() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Bus tracking enabled! You\'ll receive arrival notifications.'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _buyTicket() {
    HapticFeedback.mediumImpact();
    // Navigate to ticket purchase flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to ticket purchase...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Sticky header
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: StickyHeaderWidget(
                  routeNumber: routeData['routeNumber'] as String,
                  origin: routeData['origin'] as String,
                  destination: routeData['destination'] as String,
                  direction: routeData['direction'] as String,
                  status: routeData['status'] as String,
                  onBackPressed: () => Navigator.pop(context),
                  onVoiceAssistant: () =>
                      Navigator.pushNamed(context, '/voice-assistant'),
                ),
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Route timeline
                  RouteTimelineWidget(
                    stops: busStops,
                    currentBusStopIndex:
                        routeData['currentBusStopIndex'] as int,
                    userBoardingStopIndex:
                        routeData['userBoardingStopIndex'] as int,
                    userAlightingStopIndex:
                        routeData['userAlightingStopIndex'] as int,
                  ),

                  SizedBox(height: 2.h),

                  // Buses on route section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buses on this Route',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          height: 20.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: busesOnRoute.length,
                            itemBuilder: (context, index) {
                              return BusCapacityCardWidget(
                                busData: busesOnRoute[index],
                                isSelected: index == _selectedBusIndex,
                                onTap: () {
                                  setState(() => _selectedBusIndex = index);
                                  HapticFeedback.selectionClick();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Action buttons
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _trackBus,
                            icon: CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              size: 20,
                            ),
                            label: Text('Track This Bus'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _buyTicket,
                            icon: CustomIconWidget(
                              iconName: 'confirmation_number',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            label: Text('Buy Ticket'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Route information cards
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Route Information',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          height: 25.h,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              RouteInfoCardWidget(
                                title: 'Fare Details',
                                infoItems: fareInfo,
                                icon: Icons.currency_rupee,
                              ),
                              RouteInfoCardWidget(
                                title: 'Schedule',
                                infoItems: scheduleInfo,
                                icon: Icons.schedule,
                              ),
                              RouteInfoCardWidget(
                                title: 'Accessibility',
                                infoItems: accessibilityInfo,
                                icon: Icons.accessible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // More options button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _showMoreOptions,
                      icon: CustomIconWidget(
                        iconName: 'more_horiz',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text('More Options'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 20.h;

  @override
  double get maxExtent => 20.h;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
