// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketResponse _$TicketResponseFromJson(Map<String, dynamic> json) =>
    TicketResponse(
      isValid: json['isValid'] as bool,
      ticketId: (json['ticketId'] as num?)?.toInt(),
      message: json['message'] as String,
    );

Map<String, dynamic> _$TicketResponseToJson(TicketResponse instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'ticketId': instance.ticketId,
      'message': instance.message,
    };
