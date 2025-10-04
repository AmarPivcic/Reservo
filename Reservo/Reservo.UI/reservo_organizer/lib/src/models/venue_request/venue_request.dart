import 'package:json_annotation/json_annotation.dart';

part 'venue_request.g.dart';

@JsonSerializable()
class VenueRequest {
  final int id;
  final String? organizerName;
  final String venueName;
  final String cityName;
  final String address;
  final int capacity;
  final String? description;
  final List<int> allowedCategoryIds;
  final String suggestedCategories;
  final String state;
  final DateTime createdAt;


  VenueRequest({
    required this.id,
    this.organizerName,
    required this.venueName,
    required this.cityName,
    required this.address,
    required this.capacity,
    this.description,
    required this.suggestedCategories,
    required this.allowedCategoryIds,
    required this.state,
    required this.createdAt,
  });

  factory VenueRequest.fromJson(Map<String, dynamic> json) => _$VenueRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VenueRequestToJson(this);
}