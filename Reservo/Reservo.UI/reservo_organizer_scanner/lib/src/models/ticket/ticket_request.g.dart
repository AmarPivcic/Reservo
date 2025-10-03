// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketRequest _$TicketRequestFromJson(Map<String, dynamic> json) =>
    TicketRequest(
      eventId: (json['eventId'] as num).toInt(),
      qrCode: json['qrCode'] as String,
    );

Map<String, dynamic> _$TicketRequestToJson(TicketRequest instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'qrCode': instance.qrCode,
    };
