class LocationResult {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String? adminArea;
  final String? timezone;

  const LocationResult({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.countryCode,
    this.adminArea,
    this.timezone,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      adminArea: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  String get displayLabel {
    final parts = <String>[name];
    if (adminArea != null && adminArea!.isNotEmpty) parts.add(adminArea!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  String get subtitle {
    final parts = <String>[];
    if (adminArea != null && adminArea!.isNotEmpty) parts.add(adminArea!);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }
}
