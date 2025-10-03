import 'package:json_annotation/json_annotation.dart';

part 'ticket_response.g.dart';

@JsonSerializable()
class TicketResponse {
  bool isValid;
  int? ticketId;
  String message;

  TicketResponse({
    required this.isValid,
    this.ticketId,
    required this.message
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) => _$TicketResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TicketResponseToJson(this);
}