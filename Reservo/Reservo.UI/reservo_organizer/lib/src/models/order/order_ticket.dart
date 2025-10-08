import 'package:json_annotation/json_annotation.dart';

part 'order_ticket.g.dart';

@JsonSerializable()
class OrderTicket {
  int ticketTypeId;
  String ticketTypeName;
  int quantity;
  double unitPrice;
  double totalPrice;

  OrderTicket({
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderTicket.fromJson(Map<String, dynamic> json) => _$OrderTicketFromJson(json);
  Map<String, dynamic> toJson() => _$OrderTicketToJson(this);
}