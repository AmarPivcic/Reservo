// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
      qrCode: json['qrCode'] as String,
      state: json['state'] as String,
      orderDetailId: (json['orderDetailId'] as num).toInt(),
    );

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
      'qrCode': instance.qrCode,
      'state': instance.state,
      'orderDetailId': instance.orderDetailId,
    };
