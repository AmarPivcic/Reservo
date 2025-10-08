import 'package:json_annotation/json_annotation.dart';
import '../order/order_ticket.dart';

part 'order_details.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderDetails {
  final int orderId;
  final double totalAmount;
  final String state;
  final String orderedBy;
  final List<OrderTicket> tickets;

  OrderDetails({
    required this.orderId,
    required this.totalAmount,
    required this.state,
    required this.orderedBy,
    required this.tickets,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => _$OrderDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}