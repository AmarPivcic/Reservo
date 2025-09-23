import 'dart:convert';
import 'package:reservo_client/src/models/order/order.dart';
import 'package:reservo_client/src/models/order/order_insert.dart';
import 'package:reservo_client/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_client/src/utilities/custom_exception.dart';

class OrderProvider extends BaseProvider<Order, OrderInsert>
{
  OrderProvider() : super('Order');
  
  //   Future<Order?> createOrder(OrderInsert dto) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${BaseProvider.baseUrl}/Order/Insert'),
  //       headers: await createHeaders(),
  //       body: jsonEncode(dto.toJson())
  //     );

  //     if(response.statusCode == 200){
  //       final data = jsonDecode(response.body);
  //       return Order.fromJson(data);
  //     }

  //     else {
  //       handleHttpError(response);
  //       throw Exception('Order failed');
  //     }

  //   } on CustomException {
  //     rethrow;
  //   } catch (e) { 
  //     throw CustomException("$e");
  //   }
  // }

  Future<Order> createOrder(OrderInsert eventData) async {
    return insertResponse<Order, OrderInsert>(
      eventData,
      toJson: (d) => d.toJson(),
      fromJson: (json) => Order.fromJson(json),
    );
  }
}

