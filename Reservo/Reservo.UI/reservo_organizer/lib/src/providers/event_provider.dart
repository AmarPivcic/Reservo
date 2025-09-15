import 'dart:async';
import 'dart:convert';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/search_result.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_organizer/src/utilities/custom_exception.dart';

class EventProvider extends BaseProvider<Event, Event>
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

    queryParams['PageNumber'] = pageNumber;
    queryParams['PageSize'] = pageSize;
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

  Future<Event> activateEvent(int eventId) async {
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

  Future<Event> setEventActive(int eventId) async {
    return await activateEvent(eventId);
  }

  Future<Event> updateEvent(int eventId, EventInsertUpdate dto) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseProvider.baseUrl}/Event/$eventId/Update'),
        headers: await createHeaders(),
        body: jsonEncode(dto.toJson())
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updated = Event.fromJson(data);
        notifyListeners();
        return updated;
      }
      else {
        handleHttpError(response);
        throw Exception("Failed to update event");
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

}