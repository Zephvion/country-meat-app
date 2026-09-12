import 'package:latlong2/latlong.dart';

/// Centralized mock location source for development.
/// When real-time Firebase / GPS stream API is ready,
/// replace these static values with the live Firestore location stream.
class MockLocationData {
  // Store Location (Country Meat Central Farm Hub)
  static const LatLng storeLocation = LatLng(12.9250, 77.5897); // Jayanagar / HSR Hub, Bengaluru

  // Default Customer Destination Location
  static const LatLng customerLocation = LatLng(12.9100, 77.6400); // HSR Layout 1st Sector, Bengaluru

  // Active Delivery Partner (Driver) Location
  static const LatLng driverLocation = LatLng(12.9180, 77.6200); // En route near Silk Board / HSR 3rd Sector

  // Mock Route Polyline Points (Store -> Driver -> Customer)
  static const List<LatLng> deliveryRoute = [
    LatLng(12.9250, 77.5897), // Store Hub
    LatLng(12.9220, 77.5980),
    LatLng(12.9200, 77.6100),
    LatLng(12.9180, 77.6200), // Driver Current Position
    LatLng(12.9150, 77.6300),
    LatLng(12.9100, 77.6400), // Customer Destination
  ];

  // Preset location coordinates for search suggestions & default addresses
  static const Map<String, LatLng> presetLocations = {
    'HSR Layout': LatLng(12.9100, 77.6400),
    'Indiranagar': LatLng(12.9784, 77.6408),
    'Koramangala': LatLng(12.9352, 77.6245),
    'Hebbal': LatLng(13.0358, 77.5970),
    'Basaveshwara Nagar': LatLng(12.9866, 77.5358),
  };

  /// Helper to get coordinates for a given address title or default to HSR Layout
  static LatLng getCoordinates(String title) {
    for (final entry in presetLocations.entries) {
      if (title.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return customerLocation;
  }
}
