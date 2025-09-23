import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_client/src/models/order/order_ticket.dart';

part 'order_details.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderDetails{
  final int orderId;
  final double totalAmount;
  final String state;
  final int eventId;
  final String eventName;
  final String? eventImage;
  final String venue;
  final DateTime eventDate;
  final String city;
  final List<OrderTicket> tickets;

  OrderDetails({
    required this.orderId,
    required this.totalAmount,
    required this.state,
    required this.eventId,
    required this.eventName,
    this.eventImage,
    required this.venue,
    required this.eventDate,
    required this.city,
    required this.tickets,
  });
  factory OrderDetails.fromJson(Map<String, dynamic> json) => _$OrderDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}