import 'dart:convert';
import 'package:reservo_organizer_scanner/src/models/ticket/ticket_request.dart';
import 'package:reservo_organizer_scanner/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import '../models/ticket/ticket_response.dart';
import '../utilities/custom_exception.dart';

class TicketProvider extends BaseProvider<TicketResponse, TicketRequest>
{
 
 TicketProvider() : super('Ticket');

  Future<TicketResponse> checkTicket(int eventId, String qrCode) async
  {
    final ticketRequest = TicketRequest(
      eventId: eventId,
      qrCode: qrCode
    );

    final response = await http.post(
      Uri.parse('${BaseProvider.baseUrl}/Ticket/Validate'),
      headers: await createHeaders(),
      body: jsonEncode(ticketRequest.toJson())
    );
    if(response.statusCode == 200)
    {
      final data = jsonDecode(response.body)as Map<String, dynamic>;
      return TicketResponse.fromJson(data);
    }else {
      throw Exception("Failed to check ticket.");
    }
  }

  Future<void> markTicketAsUsed(int ticketId) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseProvider.baseUrl}/Ticket/Use/$ticketId'),
        headers: await createHeaders(),
      );
      
      if(response.statusCode == 200) {
        return;
      }
      else {
        handleHttpError(response);
        throw Exception('Marking ticket as used failed');
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

}