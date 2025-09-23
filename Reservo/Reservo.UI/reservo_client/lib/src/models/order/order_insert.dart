import 'package:json_annotation/json_annotation.dart';
import 'package:reservo_client/src/models/order_details/order_details_insert.dart';

part 'order_insert.g.dart';

@JsonSerializable()
class OrderInsert{
  int? userId;
  List<OrderDetailsInsert> orderDetails;

  OrderInsert({
    this.userId,
    required this.orderDetails,

  });

  factory OrderInsert.fromJson(Map<String, dynamic> json) => _$OrderInsertFromJson(json);

  Map<String, dynamic> toJson() => _$OrderInsertToJson(this);
}