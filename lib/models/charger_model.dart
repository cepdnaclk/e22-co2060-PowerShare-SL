class ChargerModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final bool isAvailable;
  final String ownerName;
  final double rating;

  ChargerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.isAvailable,
    required this.ownerName,
    required this.rating,
  });
}

// Sample Sri Lanka EV Charger Data
final List<ChargerModel> sampleChargers = [
  ChargerModel(
    id: '1',
    name: 'Colombo City Charger',
    address: 'Galle Face Green, Colombo 03',
    latitude: 6.9271,
    longitude: 79.8612,
    pricePerHour: 250.0,
    isAvailable: true,
    ownerName: 'Kamal Perera',
    rating: 4.5,
  ),
  ChargerModel(
    id: '2',
    name: 'Kandy Central Charger',
    address: 'Kandy City Center, Kandy',
    latitude: 7.2906,
    longitude: 80.6337,
    pricePerHour: 200.0,
    isAvailable: true,
    ownerName: 'Nimal Silva',
    rating: 4.2,
  ),
  ChargerModel(
    id: '3',
    name: 'Galle Fort Charger',
    address: 'Galle Fort, Galle',
    latitude: 6.0328,
    longitude: 80.2170,
    pricePerHour: 180.0,
    isAvailable: false,
    ownerName: 'Sunil Fernando',
    rating: 3.9,
  ),
  ChargerModel(
    id: '4',
    name: 'Negombo Beach Charger',
    address: 'Negombo Beach Road, Negombo',
    latitude: 7.2081,
    longitude: 79.8358,
    pricePerHour: 220.0,
    isAvailable: true,
    ownerName: 'Priya Jayawardena',
    rating: 4.7,
  ),
  ChargerModel(
    id: '5',
    name: 'Nugegoda Charger',
    address: 'High Level Road, Nugegoda',
    latitude: 6.8728,
    longitude: 79.8997,
    pricePerHour: 230.0,
    isAvailable: true,
    ownerName: 'Ruwan Dissanayake',
    rating: 4.3,
  ),
];