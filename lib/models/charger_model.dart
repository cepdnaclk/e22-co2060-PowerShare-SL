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

  // ✅ FIX: Backend JSON → ChargerModel
  factory ChargerModel.fromJson(Map<String, dynamic> json) {
    return ChargerModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      ownerName: json['ownerName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerHour': pricePerHour,
      'isAvailable': isAvailable,
      'ownerName': ownerName,
      'rating': rating,
    };
  }
}
