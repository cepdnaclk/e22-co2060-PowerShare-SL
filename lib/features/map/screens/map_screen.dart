import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../services/auth_service.dart';
import '../../../services/location_service.dart';
import '../../../models/charger_model.dart';
import '../../auth/screens/login_screen.dart';
import '../../booking/screens/booking_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LatLng _currentLocation = const LatLng(6.9271, 79.8612); // Default: Colombo
  ChargerModel? _selectedCharger;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoadingLocation = true);

    final location = await _locationService.getCurrentLocation();

    if (location != null && mounted) {
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
      _mapController.move(location, 13.0);
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerShare SL'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 10.0,
              onTap: (_, __) => setState(() => _selectedCharger = null),
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.powershare_sl',
              ),

              // Charger Markers
              MarkerLayer(
                markers: [
                  // Current Location Marker
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),

                  // Charger Markers
                  ...sampleChargers.map(
                    (charger) => Marker(
                      point: LatLng(charger.latitude, charger.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCharger = charger),
                        child: Icon(
                          Icons.ev_station,
                          color: charger.isAvailable
                              ? Colors.green
                              : Colors.red,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Charger Info Card (bottom popup)
          if (_selectedCharger != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.ev_station,
                            color: _selectedCharger!.isAvailable
                                ? Colors.green
                                : Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedCharger!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedCharger!.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedCharger!.isAvailable
                                  ? 'Available'
                                  : 'Busy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedCharger!.address,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              Text(' ${_selectedCharger!.rating}'),
                              const SizedBox(width: 16),
                              const Icon(Icons.person,
                                  color: Colors.grey, size: 16),
                              Text(' ${_selectedCharger!.ownerName}'),
                            ],
                          ),
                          Text(
                            'Rs. ${_selectedCharger!.pricePerHour.toInt()}/hr',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedCharger!.isAvailable
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingScreen(
                                      charger: _selectedCharger!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // My Location FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation,
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}