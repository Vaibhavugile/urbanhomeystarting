class PreferredLocation {
  final String name;
  final String placeId;
  final double latitude;
  final double longitude;

  PreferredLocation({
    required this.name,
    required this.placeId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PreferredLocation.fromMap(
    Map<String, dynamic> map,
  ) {
    return PreferredLocation(
      name: map['name'] ?? '',
      placeId: map['placeId'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
    );
  }
}