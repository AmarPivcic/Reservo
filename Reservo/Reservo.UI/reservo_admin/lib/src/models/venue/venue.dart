import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_admin/src/models/category/category.dart';

part 'venue.g.dart';

@JsonSerializable(explicitToJson: true)
class Venue {
  int id;
  String name;
  String address;
  int capacity;
  String? description;
  String? cityName;
  List<Category> categories;

  Venue(
    this.id,
    this.name,
    this.address,
    this.capacity,
    this.description,
    this.cityName,
    this.categories,
  );

    factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);

}