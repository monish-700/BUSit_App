import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_options_widget.dart';
import './widgets/location_swap_widget.dart';
import './widgets/map_preview_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/route_card_widget.dart';
import './widgets/search_input_widget.dart';

class RouteSearch extends StatefulWidget {
  @override
  _RouteSearchState createState() => _RouteSearchState();
}

class _RouteSearchState extends State<RouteSearch> {
  String _fromLocation = "Current Location";
  String _toLocation = "";
  String _selectedFilter = "fastest";
  int _selectedRouteIndex = -1;
  bool _showMap = false;

  // Mock data for route search results
  final List<Map<String, dynamic>> _routeResults = [
    {
      "id": 1,
      "routeName": "Route 45A → Metro Blue Line",
      "duration": "42 mins",
      "transfers": 1,
      "walkingDistance": "650m",
      "fare": "₹35",
      "status": "On Time",
      "description":
          "Take Bus 45A from Connaught Place to Rajiv Chowk Metro, then Blue Line to Dwarka",
      "steps": [
        {
          "type": "walk",
          "description": "Walk 5 mins to Bus Stop",
          "duration": "5 mins"
        },
        {
          "type": "bus",
          "description": "Bus 45A to Rajiv Chowk",
          "duration": "25 mins"
        },
        {
          "type": "walk",
          "description": "Walk to Metro Station",
          "duration": "3 mins"
        },
        {
          "type": "metro",
          "description": "Blue Line to Dwarka",
          "duration": "15 mins"
        },
      ]
    },
    {
      "id": 2,
      "routeName": "Direct Bus 620",
      "duration": "55 mins",
      "transfers": 0,
      "walkingDistance": "400m",
      "fare": "₹25",
      "status": "Delayed",
      "description":
          "Direct bus service from Connaught Place to Dwarka Sector 21",
      "steps": [
        {
          "type": "walk",
          "description": "Walk 4 mins to Bus Stop",
          "duration": "4 mins"
        },
        {
          "type": "bus",
          "description": "Bus 620 Direct to Dwarka",
          "duration": "51 mins"
        },
      ]
    },
    {
      "id": 3,
      "routeName": "Route 34 → 405 → Metro",
      "duration": "48 mins",
      "transfers": 2,
      "walkingDistance": "800m",
      "fare": "₹30",
      "status": "On Time",
      "description":
          "Multi-transfer route via Karol Bagh with metro connection",
      "steps": [
        {
          "type": "walk",
          "description": "Walk 6 mins to Bus Stop",
          "duration": "6 mins"
        },
        {
          "type": "bus",
          "description": "Bus 34 to Karol Bagh",
          "duration": "18 mins"
        },
        {
          "type": "bus",
          "description": "Bus 405 to Metro Station",
          "duration": "12 mins"
        },
        {
          "type": "metro",
          "description": "Blue Line to Dwarka",
          "duration": "12 mins"
        },
      ]
    },
  ];

  // Mock data for recent searches
  final List<Map<String, dynamic>> _recentSearches = [
    {
      "from": "Connaught Place",
      "to": "Dwarka Sector 21",
      "timestamp": "2 hours ago",
    },
    {
      "from": "India Gate",
      "to": "Gurgaon Cyber City",
      "timestamp": "Yesterday",
    },
    {
      "from": "Red Fort",
      "to": "Noida Sector 62",
      "timestamp": "3 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchSection(),
            if (_showMap) _buildMapSection(),
            Expanded(
              child: _buildResultsSection(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildVoiceSearchFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 1.0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      title: Text(
        "Route Search",
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _showFilterOptions,
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _showMap = !_showMap),
          child: Container(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: _showMap ? 'list' : 'map',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          SearchInputWidget(
            label: "From",
            hintText: "Enter pickup location",
            value: _fromLocation,
            onTap: _selectFromLocation,
            isFromField: true,
          ),
          LocationSwapWidget(
            onSwap: _swapLocations,
          ),
          SearchInputWidget(
            label: "To",
            hintText: "Enter destination",
            value: _toLocation,
            onTap: _selectToLocation,
          ),
          if (_toLocation.isNotEmpty) _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: _performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Search Routes",
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return MapPreviewWidget(
      fromLocation: LatLng(28.6139, 77.2090), // Connaught Place
      toLocation: LatLng(28.5921, 77.0460), // Dwarka
      routePoints: [
        LatLng(28.6139, 77.2090),
        LatLng(28.6100, 77.1950),
        LatLng(28.6000, 77.1800),
        LatLng(28.5921, 77.0460),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_toLocation.isEmpty) {
      return RecentSearchesWidget(
        recentSearches: _recentSearches,
        onSearchTap: _selectRecentSearch,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Route Options",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text(
                    "${_routeResults.length} routes found",
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _routeResults.length,
            itemBuilder: (context, index) {
              return RouteCardWidget(
                routeData: _routeResults[index],
                isSelected: _selectedRouteIndex == index,
                onTap: () => _selectRoute(index),
              );
            },
          ),
          if (_selectedRouteIndex >= 0) _buildStartJourneyButton(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildStartJourneyButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: _startJourney,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'navigation',
              color: AppTheme.lightTheme.colorScheme.onSecondary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              "Start Journey",
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSearchFAB() {
    return FloatingActionButton(
      onPressed: _startVoiceSearch,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      child: CustomIconWidget(
        iconName: 'mic',
        color: AppTheme.lightTheme.colorScheme.onTertiary,
        size: 24,
      ),
    );
  }

  void _selectFromLocation() {
    // Mock location selection
    setState(() {
      _fromLocation = "Connaught Place, New Delhi";
    });
  }

  void _selectToLocation() {
    // Mock location selection
    setState(() {
      _toLocation = "Dwarka Sector 21, New Delhi";
    });
  }

  void _swapLocations() {
    if (_toLocation.isNotEmpty) {
      setState(() {
        final temp = _fromLocation;
        _fromLocation = _toLocation;
        _toLocation = temp;
      });
    }
  }

  void _performSearch() {
    // Mock search - results are already loaded
    setState(() {
      _selectedRouteIndex = -1;
    });
  }

  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
    });
  }

  void _selectRecentSearch(Map<String, dynamic> search) {
    setState(() {
      _fromLocation = search["from"] as String;
      _toLocation = search["to"] as String;
    });
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: FilterOptionsWidget(
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
      ),
    );
  }

  void _startJourney() {
    if (_selectedRouteIndex >= 0) {
      Navigator.pushNamed(context, '/live-bus-map');
    }
  }

  void _startVoiceSearch() {
    Navigator.pushNamed(context, '/voice-assistant');
  }
}
