import 'dart:async';
import 'dart:convert';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/search_result.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_organizer/src/utilities/custom_exception.dart';

class EventProvider extends BaseProvider<Event, EventInsertUpdate>
{
  List<Event> events = [];
  bool isLoading = false;
  int countOfEvents = 0;

  EventProvider() : super('Event');

  Future<void> getEvents({
    int? pageNumber,
    int? pageSize,
    String? nameFilter,
    String? state,
    String? cityFilter,
    String? venueFilter,
    DateTime? date,
  }) async {
    isLoading = true;
    notifyListeners();

    Map<String, dynamic> queryParams = {};

    if(pageNumber != null){
        queryParams['PageNumber'] = pageNumber.toString();;
    } 
    if(pageSize != null){
        queryParams['PageSize'] = pageSize.toString();;
    }
    if(nameFilter != null && nameFilter.isNotEmpty){
        queryParams['Name'] = nameFilter;
        }
    if(state != null && state.isNotEmpty){
      queryParams['State'] = state;
    }
    if(cityFilter != null && cityFilter.isNotEmpty){
      queryParams['City'] = cityFilter;
    }
    if(venueFilter != null && venueFilter.isNotEmpty){
      queryParams['Venue'] = venueFilter;
    }
    if(date != null){
      queryParams['Date'] = date.toIso8601String();
    }

    try {
      SearchResult<Event> searchResult = await get(
        filter: queryParams,
        fromJson: (json) => Event.fromJson(json),
        customEndpoint: 'GetByToken'
      );
    events = searchResult.result;
    countOfEvents = searchResult.count;
    isLoading = false;
    notifyListeners();
    } catch (e) {
      events = [];
      countOfEvents = 0;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Event> insertEvent(EventInsertUpdate eventData) async {
    return insertResponse<Event, EventInsertUpdate>(
      eventData,
      toJson: (d) => d.toJson(),
      fromJson: (json) => Event.fromJson(json),
      customEndpoint: 'Insert'
    );
  }

  Future<Event> setEventActive(int eventId) async {
    try {
      final response = await http.patch(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId/Activate'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final event = Event.fromJson(data);
        return event;
      }
      else {
        handleHttpError(response);
        throw Exception('Activate failed');
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

  Future<Event> setEventDraft(int eventId) async {
    try {
      final response = await http.patch(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId/Draft'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Event.fromJson(data);
      }
      else {
        handleHttpError(response);
        throw Exception("Failed to set event to draft");
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

  Future<Event> setEventComplete(int eventId) async {
    try {
      final response = await http.patch(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId/Complete'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Event.fromJson(data);
      }
      else {
        handleHttpError(response);
        throw Exception("Failed to set event to completed");
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

  Future<Event> cancelEvent(int eventId) async {
    try {
      final response = await http.patch(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId/Cancel'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final event = Event.fromJson(data);
        return event;
      }
      else {
        handleHttpError(response);
        throw Exception('Cancel failed');
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }


  Future<void> updateEvent(int eventId, EventInsertUpdate dto) async {
    await update(id: eventId, item: dto, toJson:(dto) => dto.toJson());
  }

  Future<void> deleteEvent(int eventId) async{
    try {
      final response = await http.delete(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId'),
        headers: await createHeaders(),
      );

      print(Uri.parse('${BaseProvider.baseUrl}/Event/$eventId'));


      if(response.statusCode == 200) {
        return;
      }
      else {
        handleHttpError(response);
        throw Exception('Delete failed');
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

}