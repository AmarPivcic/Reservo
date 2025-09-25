// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderTicket _$OrderTicketFromJson(Map<String, dynamic> json) => OrderTicket(
      ticketTypeName: json['ticketTypeName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      tickets: (json['tickets'] as List<dynamic>)
          .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderTicketToJson(OrderTicket instance) =>
    <String, dynamic>{
      'ticketTypeName': instance.ticketTypeName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'tickets': instance.tickets.map((e) => e.toJson()).toList(),
    };
