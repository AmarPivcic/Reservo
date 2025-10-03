import 'package:json_annotation/json_annotation.dart';

part 'ticket_request.g.dart';

@JsonSerializable()
class TicketRequest {
  int eventId;
  String qrCode;

  TicketRequest({
    required this.eventId,
    required this.qrCode
  });

  factory TicketRequest.fromJson(Map<String, dynamic> json) => _$TicketRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TicketRequestToJson(this);
}