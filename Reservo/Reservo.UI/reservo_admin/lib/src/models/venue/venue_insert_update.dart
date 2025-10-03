import 'package:json_annotation/json_annotation.dart';

part 'venue_insert_update.g.dart';

@JsonSerializable()
class VenueInsertUpdate {
  String name;
  String address;
  int capacity;
  String? description;
  int? cityId;
  List<int> categoryIds;

  VenueInsertUpdate({
    required this.name,
    required this.address,
    required this.capacity,
    this.description,
    this.cityId,
    required this.categoryIds,
  });

  factory VenueInsertUpdate.fromJson(Map<String, dynamic> json) => _$VenueInsertUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$VenueInsertUpdateToJson(this);
}