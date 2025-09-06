import 'package:json_annotation/json_annotation.dart';

part 'ticket_type_insert.g.dart';

@JsonSerializable()
class TicketTypeInsert {
  String name;
  String? description;
  double price;
  int quantity;

  TicketTypeInsert(
    this.name,
    this.description,
    this.price,
    this.quantity
  );

  factory TicketTypeInsert.fromJson(Map<String, dynamic> json) => _$TicketTypeInsertFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeInsertToJson(this);
}