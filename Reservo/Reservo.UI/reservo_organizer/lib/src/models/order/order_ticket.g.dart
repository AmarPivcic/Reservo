// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTicket _$OrderTicketFromJson(Map<String, dynamic> json) => OrderTicket(
      ticketTypeId: (json['ticketTypeId'] as num).toInt(),
      ticketTypeName: json['ticketTypeName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderTicketToJson(OrderTicket instance) =>
    <String, dynamic>{
      'ticketTypeId': instance.ticketTypeId,
      'ticketTypeName': instance.ticketTypeName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };
