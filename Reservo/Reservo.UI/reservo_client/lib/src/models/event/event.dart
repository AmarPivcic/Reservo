import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_client/src/models/ticket_type/ticket_type.dart';

part 'event.g.dart';

@JsonSerializable(explicitToJson: false)
class Event {
  int id;
  String name;
  String description;
  DateTime startDate;
  DateTime endDate;
  String state;
  String? categoryName;
  int categoryId;
  String? venueName;
  int venueId;
  String? cityName;
  int cityId;
  String? image;
  List<TicketType> ticketTypes;
  double? averageRating;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.state,
    required this.categoryId,
    required this.venueId,
    required this.cityId,
    this.categoryName,
    this.venueName,
    this.cityName,
    this.image,
    this.averageRating,
    required this.ticketTypes
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}

