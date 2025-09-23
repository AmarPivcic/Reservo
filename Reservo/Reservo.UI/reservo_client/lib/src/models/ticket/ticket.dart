import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final String qrCode;
  final String state;
  final int orderDetailId;

    Ticket({
    required this.qrCode,
    required this.state,
    required this.orderDetailId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  Map<String, dynamic> toJson() => _$TicketToJson(this);
}