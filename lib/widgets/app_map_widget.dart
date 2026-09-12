import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/mock_location_data.dart';
import '../theme/app_theme.dart';

enum AppMapMode {
  /// Delivery tracking mode with Store, Driver, Customer Destination markers and route polyline
  tracking,

  /// Full interactive location picker mode for address selection
  picker,

  /// Small map preview card for Address Details screen
  preview,
}

class AppMapWidget extends StatefulWidget {
  final AppMapMode mode;
  final LatLng? center;
  final double zoom;
  final LatLng? driverLocation;
  final LatLng? storeLocation;
  final LatLng? destinationLocation;
  final List<LatLng>? routePoints;
  final void Function(LatLng newCenter, bool isGesture)? onPositionChanged;
  final VoidCallback? onTap;

  const AppMapWidget({
    super.key,
    required this.mode,
    this.center,
    this.zoom = 15.0,
    this.driverLocation,
    this.storeLocation,
    this.destinationLocation,
    this.routePoints,
    this.onPositionChanged,
    this.onTap,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _effectiveCenter {
    if (widget.center != null) return widget.center!;
    if (widget.mode == AppMapMode.tracking) {
      return widget.driverLocation ?? MockLocationData.driverLocation;
    }
    return MockLocationData.customerLocation;
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.mode != AppMapMode.preview;

    Widget mapWidget = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _effectiveCenter,
        initialZoom: widget.mode == AppMapMode.preview ? 14.5 : widget.zoom,
        interactionOptions: InteractionOptions(
          flags: isInteractive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
        onPositionChanged: (pos, hasGesture) {
          if (widget.onPositionChanged != null) {
            widget.onPositionChanged!(pos.center, hasGesture);
          }
        },
      ),
      children: [
        // Real OpenStreetMap Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.countrymeat.app',
        ),

        // Route Polyline Layer (Tracking Mode)
        if (widget.mode == AppMapMode.tracking)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints ?? MockLocationData.deliveryRoute,
                strokeWidth: 4.5,
                color: AppColors.brandRed,
              ),
            ],
          ),

        // Markers Layer
        MarkerLayer(
          markers: [
            if (widget.mode == AppMapMode.tracking) ...[
              // Store Marker
              Marker(
                point: widget.storeLocation ?? MockLocationData.storeLocation,
                width: 70,
                height: 54,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.brandRed,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: const Text(
                        'Farm Store',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.gray900),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Destination Marker
              Marker(
                point: widget.destinationLocation ?? MockLocationData.customerLocation,
                width: 80,
                height: 54,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: const Text(
                        'Delivery Address',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.gray900),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Delivery Partner Marker
              Marker(
                point: widget.driverLocation ?? MockLocationData.driverLocation,
                width: 90,
                height: 54,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.elevated,
                      ),
                      child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray900,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '🛵 Delivery Partner',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (widget.mode == AppMapMode.preview) ...[
              // Preview Pin Marker
              Marker(
                point: _effectiveCenter,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.brandRed,
                  size: 36,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    // In Picker mode: render fixed center pin overlay
    if (widget.mode == AppMapMode.picker) {
      mapWidget = Stack(
        children: [
          mapWidget,
          // Fixed Centered Pin Marker
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Blue accuracy circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                    border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                  ),
                ),
                // Pin icon offset so its tip points right at center
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.brandRed,
                    size: 42,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(
          absorbing: widget.mode == AppMapMode.preview,
          child: mapWidget,
        ),
      );
    }

    return mapWidget;
  }
}
