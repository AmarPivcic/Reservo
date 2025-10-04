import 'package:json_annotation/json_annotation.dart';

part 'venue_request_insert.g.dart';

@JsonSerializable()
class VenueRequestInsert {
  final String venueName;
  final String cityName;
  final String address;
  final int capacity;
  final String state;
  final List<int> allowedCategoryIds;
  final String? suggestedCategories;

  VenueRequestInsert({
    required this.venueName,
    required this.cityName,
    required this.address,
    required this.capacity,
    required this.state,
    required this.allowedCategoryIds,
    this.suggestedCategories,
  });

  factory VenueRequestInsert.fromJson(Map<String, dynamic> json) => _$VenueRequestInsertFromJson(json);

  Map<String, dynamic> toJson() => _$VenueRequestInsertToJson(this);
}