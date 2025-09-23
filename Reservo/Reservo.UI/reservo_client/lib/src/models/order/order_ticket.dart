import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_client/src/models/ticket/ticket.dart';

part 'order_ticket.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderTicket{
  final String ticketTypeName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final List<Ticket> tickets;

  OrderTicket({
    required this.ticketTypeName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.tickets,
  });

  factory OrderTicket.fromJson(Map<String, dynamic> json) => _$OrderTicketFromJson(json);

  Map<String, dynamic> toJson() => _$OrderTicketToJson(this);
}