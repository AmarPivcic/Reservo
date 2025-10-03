import 'package:json_annotation/json_annotation.dart';

part 'venue_request_insert.g.dart';

@JsonSerializable()
class VenueRequestInsert {
  final String venueName;
  final String cityName;
  final String address;
  final int capacity;
  final String? description;
  final String allowedCategories;

  VenueRequestInsert({
    required this.venueName,
    required this.cityName,
    required this.address,
    required this.capacity,
    this.description,
    required this.allowedCategories,
  });

  factory VenueRequestInsert.fromJson(Map<String, dynamic> json) => _$VenueRequestInsertFromJson(json);

  Map<String, dynamic> toJson() => _$VenueRequestInsertToJson(this);
}