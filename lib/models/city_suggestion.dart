class CitySuggestion {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    // OpenWeatherMap Geocoding API often returns an array of results
    return CitySuggestion(
      name: json['name'] as String,
      // 'country' and sometimes 'state' are provided; we use the country code
      country: json['country'] as String,
      latitude: json['lat'] as double,
      longitude: json['lon'] as double,
    );
  }

  // Display name for the suggestion list
  String get displayName => '$name, $country';
}
