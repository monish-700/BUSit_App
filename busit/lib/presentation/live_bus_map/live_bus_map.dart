import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bus_marker_info_sheet.dart';
import './widgets/map_search_bar.dart';
import './widgets/map_tab_navigation.dart';
import './widgets/nearby_stops_sheet.dart';
import './widgets/route_filter_chips.dart';

class LiveBusMap extends StatefulWidget {
  const LiveBusMap({Key? key}) : super(key: key);

  @override
  State<LiveBusMap> createState() => _LiveBusMapState();
}

class _LiveBusMapState extends State<LiveBusMap> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  bool _isLocationPermissionGranted = false;
  bool _showBusInfoSheet = false;
  bool _showNearbyStopsSheet = false;
  Map<String, dynamic>? _selectedBusData;
  List<String> _activeFilters = [];
  String _searchQuery = '';

  // Mock data for bus locations
  final List<Map<String, dynamic>> _busLocations = [
    {
      'id': 'bus_001',
      'routeNumber': '45',
      'destination': 'City Center',
      'latitude': 28.6139,
      'longitude': 77.2090,
      'capacity': 75,
      'busType': 'Electric',
      'isAcBus': true,
      'nextStops': [
        {'name': 'Central Station', 'eta': '3 min', 'distance': '0.8 km'},
        {'name': 'Market Square', 'eta': '7 min', 'distance': '1.5 km'},
        {'name': 'Tech Park', 'eta': '12 min', 'distance': '2.3 km'},
      ],
    },
    {
      'id': 'bus_002',
      'routeNumber': '12',
      'destination': 'Airport Express',
      'latitude': 28.6129,
      'longitude': 77.2080,
      'capacity': 45,
      'busType': 'CNG',
      'isAcBus': true,
      'nextStops': [
        {'name': 'Terminal 1', 'eta': '5 min', 'distance': '1.2 km'},
        {'name': 'Terminal 3', 'eta': '15 min', 'distance': '3.8 km'},
      ],
    },
    {
      'id': 'bus_003',
      'routeNumber': '23',
      'destination': 'University Campus',
      'latitude': 28.6149,
      'longitude': 77.2100,
      'capacity': 30,
      'busType': 'Diesel',
      'isAcBus': false,
      'nextStops': [
        {'name': 'Library Gate', 'eta': '4 min', 'distance': '0.9 km'},
        {'name': 'Sports Complex', 'eta': '8 min', 'distance': '1.7 km'},
        {'name': 'Hostel Block', 'eta': '13 min', 'distance': '2.5 km'},
      ],
    },
    {
      'id': 'bus_004',
      'routeNumber': '67',
      'destination': 'Shopping Mall',
      'latitude': 28.6159,
      'longitude': 77.2070,
      'capacity': 85,
      'busType': 'Electric',
      'isAcBus': true,
      'nextStops': [
        {'name': 'Food Court', 'eta': '2 min', 'distance': '0.5 km'},
        {'name': 'Cinema Hall', 'eta': '6 min', 'distance': '1.1 km'},
      ],
    },
  ];

  // Mock data for bus stops
  final List<Map<String, dynamic>> _busStops = [
    {
      'id': 'stop_001',
      'name': 'Central Bus Station',
      'latitude': 28.6135,
      'longitude': 77.2085,
    },
    {
      'id': 'stop_002',
      'name': 'Market Square Stop',
      'latitude': 28.6145,
      'longitude': 77.2095,
    },
    {
      'id': 'stop_003',
      'name': 'Hospital Junction',
      'latitude': 28.6125,
      'longitude': 77.2075,
    },
    {
      'id': 'stop_004',
      'name': 'Tech Park Gate',
      'latitude': 28.6155,
      'longitude': 77.2105,
    },
  ];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14.0,
  );

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _createMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    if (kIsWeb) {
      setState(() {
        _isLocationPermissionGranted = true;
      });
      return;
    }

    final status = await Permission.location.request();
    setState(() {
      _isLocationPermissionGranted = status.isGranted;
    });

    if (!status.isGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Location Permission Required',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'BUSit needs location access to show nearby buses and stops. Please enable location permission in settings.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _createMarkers() {
    final Set<Marker> markers = {};

    // Add bus markers
    for (final bus in _busLocations) {
      if (_activeFilters.isEmpty ||
          _activeFilters.contains('Route ${bus['routeNumber']}')) {
        markers.add(
          Marker(
            markerId: MarkerId(bus['id'] as String),
            position: LatLng(
              bus['latitude'] as double,
              bus['longitude'] as double,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getBusMarkerColor(bus['capacity'] as int),
            ),
            infoWindow: InfoWindow(
              title: 'Route ${bus['routeNumber']}',
              snippet: bus['destination'] as String,
            ),
            onTap: () => _onBusMarkerTapped(bus),
          ),
        );
      }
    }

    // Add bus stop markers
    for (final stop in _busStops) {
      markers.add(
        Marker(
          markerId: MarkerId(stop['id'] as String),
          position: LatLng(
            stop['latitude'] as double,
            stop['longitude'] as double,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: stop['name'] as String,
            snippet: 'Bus Stop',
          ),
          onTap: () => _onBusStopTapped(stop),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getBusMarkerColor(int capacity) {
    if (capacity >= 80) return BitmapDescriptor.hueRed;
    if (capacity >= 60) return BitmapDescriptor.hueOrange;
    if (capacity >= 40) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueGreen;
  }

  void _onBusMarkerTapped(Map<String, dynamic> busData) {
    setState(() {
      _selectedBusData = busData;
      _showBusInfoSheet = true;
      _showNearbyStopsSheet = false;
    });
  }

  void _onBusStopTapped(Map<String, dynamic> stopData) {
    // Show stop info or context menu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on ${stopData['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _centerMapOnUserLocation() {
    if (_mapController != null && _isLocationPermissionGranted) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(28.6139, 77.2090), // Mock user location
            zoom: 16.0,
          ),
        ),
      );

      // Provide haptic feedback
      if (!kIsWeb) {
        // HapticFeedback.lightImpact(); // Uncomment if haptic feedback is needed
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isNotEmpty) {
      // Filter buses based on search query
      final filteredBuses = _busLocations
          .where((bus) =>
              (bus['routeNumber'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (bus['destination'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      if (filteredBuses.isNotEmpty) {
        final firstBus = filteredBuses.first;
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                firstBus['latitude'] as double,
                firstBus['longitude'] as double,
              ),
              zoom: 16.0,
            ),
          ),
        );
      }
    }
  }

  void _onVoiceSearch() {
    Navigator.pushNamed(context, '/voice-assistant');
  }

  void _onFiltersChanged(List<String> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _createMarkers();
  }

  void _showNearbyStops() {
    setState(() {
      _showNearbyStopsSheet = true;
      _showBusInfoSheet = false;
    });
  }

  void _closeBusInfoSheet() {
    setState(() {
      _showBusInfoSheet = false;
      _selectedBusData = null;
    });
  }

  void _closeNearbyStopsSheet() {
    setState(() {
      _showNearbyStopsSheet = false;
    });
  }

  void _viewBusDetails() {
    if (_selectedBusData != null) {
      Navigator.pushNamed(context, '/bus-details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Search bar
                MapSearchBar(
                  onSearch: _onSearch,
                  onVoiceSearch: _onVoiceSearch,
                ),

                // Filter chips
                RouteFilterChips(
                  onFiltersChanged: _onFiltersChanged,
                ),

                // Map
                Expanded(
                  child: _isLocationPermissionGranted
                      ? GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: _initialPosition,
                          markers: _markers,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          compassEnabled: true,
                          rotateGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          onTap: (position) {
                            // Hide bottom sheets when tapping on map
                            if (_showBusInfoSheet || _showNearbyStopsSheet) {
                              setState(() {
                                _showBusInfoSheet = false;
                                _showNearbyStopsSheet = false;
                                _selectedBusData = null;
                              });
                            }
                          },
                        )
                      : Container(
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'location_off',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  size: 15.w,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Location Permission Required',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Enable location access to view live bus tracking',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 3.h),
                                ElevatedButton(
                                  onPressed: _requestLocationPermission,
                                  child: const Text('Enable Location'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),

            // Floating action button for centering map
            if (_isLocationPermissionGranted && _isMapReady)
              Positioned(
                right: 4.w,
                bottom:
                    _showBusInfoSheet || _showNearbyStopsSheet ? 45.h : 20.h,
                child: FloatingActionButton(
                  onPressed: _centerMapOnUserLocation,
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  elevation: 4,
                  child: CustomIconWidget(
                    iconName: 'my_location',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ),
              ),

            // Nearby stops button
            if (_isLocationPermissionGranted &&
                _isMapReady &&
                !_showNearbyStopsSheet)
              Positioned(
                right: 4.w,
                bottom: _showBusInfoSheet ? 52.h : 27.h,
                child: FloatingActionButton(
                  onPressed: _showNearbyStops,
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
                  elevation: 4,
                  heroTag: 'nearby_stops',
                  child: CustomIconWidget(
                    iconName: 'near_me',
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    size: 6.w,
                  ),
                ),
              ),

            // Bus info bottom sheet
            if (_showBusInfoSheet && _selectedBusData != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10.h,
                child: BusMarkerInfoSheet(
                  busData: _selectedBusData!,
                  onClose: _closeBusInfoSheet,
                  onViewDetails: _viewBusDetails,
                ),
              ),

            // Nearby stops bottom sheet
            if (_showNearbyStopsSheet)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10.h,
                child: NearbyStopsSheet(
                  onClose: _closeNearbyStopsSheet,
                ),
              ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: MapTabNavigation(
        currentIndex: 0, // Map tab is active
        onTabChanged: (index) {
          // Tab navigation is handled within the widget
        },
      ),
    );
  }
}
