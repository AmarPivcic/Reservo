import 'package:json_annotation/json_annotation.dart';

part 'venue.g.dart';

@JsonSerializable()
class Venue {
  int id;
  String name;
  String address;
  int capacity;
  String? description;
  String cityName;

  Venue(
    this.id,
    this.name,
    this.address,
    this.capacity,
    this.description,
    this.cityName
  );

    factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);
}