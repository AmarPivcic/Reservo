import 'package:json_annotation/json_annotation.dart';

part 'ticket_type.g.dart';

@JsonSerializable()
class TicketType {
  int id;
  String name;
  String? description;
  double price;
  int quantity;

  TicketType(
    this.id,
    this.name,
    this.description,
    this.price,
    this.quantity
  );

  factory TicketType.fromJson(Map<String, dynamic> json) => _$TicketTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TicketTypeToJson(this);
}