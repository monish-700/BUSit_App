import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MapPreviewWidget extends StatefulWidget {
  final LatLng? fromLocation;
  final LatLng? toLocation;
  final List<LatLng> routePoints;

  const MapPreviewWidget({
    Key? key,
    this.fromLocation,
    this.toLocation,
    this.routePoints = const [],
  }) : super(key: key);

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMarkersAndPolylines();
  }

  void _setupMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    // Add from marker
    if (widget.fromLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('from'),
          position: widget.fromLocation!,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'From'),
        ),
      );
    }

    // Add to marker
    if (widget.toLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('to'),
          position: widget.toLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'To'),
        ),
      );
    }

    // Add route polyline
    if (widget.routePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: widget.routePoints,
          color: AppTheme.lightTheme.colorScheme.primary,
          width: 4,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default location (Delhi) if no locations provided
    final defaultLocation = LatLng(28.6139, 77.2090);
    final initialLocation =
        widget.fromLocation ?? widget.toLocation ?? defaultLocation;

    return Container(
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLocation,
            zoom: 12.0,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _fitMarkersInView();
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
        ),
      ),
    );
  }

  void _fitMarkersInView() {
    if (_mapController == null || _markers.isEmpty) return;

    if (_markers.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 15.0),
      );
    } else if (_markers.length > 1) {
      final bounds = _calculateBounds(_markers.map((m) => m.position).toList());
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (LatLng position in positions) {
      minLat = minLat < position.latitude ? minLat : position.latitude;
      maxLat = maxLat > position.latitude ? maxLat : position.latitude;
      minLng = minLng < position.longitude ? minLng : position.longitude;
      maxLng = maxLng > position.longitude ? maxLng : position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
