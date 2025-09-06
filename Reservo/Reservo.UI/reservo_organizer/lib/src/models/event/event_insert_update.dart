import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type_insert.dart';

part 'event_insert_update.g.dart';

@JsonSerializable(explicitToJson: false)
class EventInsertUpdate {
  String name;
  String? description;
  DateTime startDate;
  DateTime endDate;
  int categoryId;
  int venueId;
  String? image;
  List<TicketTypeInsert> ticketTypes;

  EventInsertUpdate({
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
    required this.venueId,
    this.image,
    required this.ticketTypes,
  });

  factory EventInsertUpdate.fromJson(Map<String, dynamic> json) =>
      _$EventInsertUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$EventInsertUpdateToJson(this);
}