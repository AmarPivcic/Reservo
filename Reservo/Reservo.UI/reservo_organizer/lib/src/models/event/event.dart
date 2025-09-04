import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event{
  int id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String state;
  String? categoryName;
  String venueName;
  String cityName;
  String? image;

  Event(
    this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.state,
    this.categoryName,
    this.venueName,
    this.cityName,
    this.image
  );

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
  
}
