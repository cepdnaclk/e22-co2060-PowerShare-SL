import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/charger_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../booking/screens/booking_screen.dart';
import '../../host/screens/add_charger_screen.dart';
import '../../booking/screens/my_bookings_screen.dart';
import '../../auth/screens/role_selection_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(6.9271, 79.8612); // Colombo default
  ChargerModel? _selectedCharger;
  bool _isLoadingLocation = false;

  // ✅ FIX: hardcoded list → API list
  List<ChargerModel> _chargers = [];
  bool _isLoadingChargers = false;
  String? _chargerError;

  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _getUserLocation();
    _fetchChargers(); // ✅ Backend-ගෙන් chargers load
  }

  Future<void> _loadUserInfo() async {
    final info = await AuthService().getUserInfo();
    setState(() => _userName = info['name'] ?? '');
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentLocation, 13.0);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
    setState(() => _isLoadingLocation = false);
  }

  // ✅ FIX: Backend API-ගෙන් chargers ලබා ගැනීම
  Future<void> _fetchChargers() async {
    setState(() {
      _isLoadingChargers = true;
      _chargerError = null;
    });

    final chargers = await ApiService.getChargers();

    setState(() {
      _isLoadingChargers = false;
      if (chargers.isNotEmpty) {
        _chargers = chargers;
      } else {
        _chargerError = 'Chargers load කරන්න බැරි වුණා. Retry කරන්න.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerShare SL'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoadingLocation || _isLoadingChargers)
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
          if (_userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _userName.split(' ').first,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 10.0,
              onTap: (_, __) => setState(() => _selectedCharger = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.powershare_sl',
              ),
              MarkerLayer(
                markers: [
                  // User location marker
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
                  // ✅ FIX: API chargers map markers
                  ..._chargers.map(
                    (charger) => Marker(
                      point: LatLng(charger.latitude, charger.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCharger = charger),
                        child: Icon(
                          Icons.ev_station,
                          color: charger.isAvailable ? Colors.green : Colors.red,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✅ Error banner
          if (_chargerError != null)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _chargerError!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchChargers,
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

          // Charger info card
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
                              _selectedCharger!.isAvailable ? 'Available' : 'Busy',
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
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(' ${_selectedCharger!.rating}'),
                              const SizedBox(width: 16),
                              const Icon(Icons.person, color: Colors.grey, size: 16),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_charger',
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddChargerScreen()),
              );
              if (added == true) _fetchChargers();
            },
            backgroundColor: Colors.green,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Charger', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: _getUserLocation,
            backgroundColor: const Color(0xFF1E3A5F),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
