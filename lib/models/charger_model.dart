class ChargerModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerKwh;
  final double powerKw;
  final bool isAvailable;
  final String ownerName;
  final double rating;

  ChargerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerKwh,
    required this.powerKw,
    required this.isAvailable,
    required this.ownerName,
    required this.rating,
  });

  factory ChargerModel.fromJson(Map<String, dynamic> json) {
    return ChargerModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // backward compatible — old chargers had pricePerHour
      pricePerKwh: (json['pricePerKwh'] as num?)?.toDouble() ??
          (json['pricePerHour'] as num?)?.toDouble() ?? 50.0,
      powerKw: (json['powerKw'] as num?)?.toDouble() ?? 7.4,
      isAvailable: json['isAvailable'] ?? true,
      ownerName: json['ownerName'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Accurate cost calculation
  // kWh charged = powerKw × hours
  // total cost  = kWh × pricePerKwh
  double calculateCost(double hours) => powerKw * hours * pricePerKwh;

  // Estimated cost per hour (for display on map card)
  double get estimatedCostPerHour => powerKw * pricePerKwh;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'pricePerKwh': pricePerKwh,
        'powerKw': powerKw,
        'isAvailable': isAvailable,
        'ownerName': ownerName,
        'rating': rating,
      };
}