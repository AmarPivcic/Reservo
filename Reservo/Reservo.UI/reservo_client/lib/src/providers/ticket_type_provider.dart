import 'dart:convert';
import 'package:reservo_client/src/models/ticket_type/ticket_type.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_client/src/providers/base_provider.dart';

class TicketTypeProvider extends BaseProvider<TicketType, TicketType> {

  List<TicketType> ticketTypes = [];

  TicketTypeProvider() : super('TicketType');

  Future<List<TicketType>> getTicketTypesForEvent(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseProvider.baseUrl}/TicketType/GetByEvent/$eventId'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200){
        final data = jsonDecode(response.body) as List;
        ticketTypes = data.map((json) => TicketType.fromJson(json)).toList();
        notifyListeners();
        return ticketTypes;
      }
      else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

   Future<TicketType?> getTicketTypeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${BaseProvider.baseUrl}/TicketType/Get/$id'),
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TicketType.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}