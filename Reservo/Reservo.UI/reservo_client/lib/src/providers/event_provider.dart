import 'dart:async';
import 'dart:convert';
import 'package:reservo_client/src/models/event/event.dart';
import 'package:reservo_client/src/models/search_result.dart';
import 'package:reservo_client/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;


class EventProvider extends BaseProvider<Event, Event>
{
  List<Event> events = [];
  bool isLoading = false;
  int countOfEvents = 0;

  EventProvider() : super('Event');
  
  Future<void> getEvents({
    int? categoryId,
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
    if(categoryId != null){
        queryParams['CategoryId'] = categoryId.toString();
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

  Future<void> getRatedEvents() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(        
        Uri.parse('${BaseProvider.baseUrl}/Event/GetByRating'),
        headers: await createHeaders()
        );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        events = data.map((eventJson) => Event.fromJson(eventJson)).toList();
        countOfEvents = events.length;
      } else {
        events = [];
        countOfEvents = 0;
      }
    } catch (e) {
      events = [];
      countOfEvents = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecommended() async {
    isLoading = true;
    notifyListeners();
    print("HIT REC");
    try {
      final response = await http.get(        
        Uri.parse('${BaseProvider.baseUrl}/Event/GetRecommended'),
        headers: await createHeaders()
        );
        print(response.body);
        print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        events = data.map((eventJson) => Event.fromJson(eventJson)).toList();
        countOfEvents = events.length;
      } else {
        events = [];
        countOfEvents = 0;
      }
    } catch (e) {
      events = [];
      countOfEvents = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(int eventId) async {
    try {
      final response = await http.post(        
        Uri.parse('${BaseProvider.baseUrl}/Event/UpdateProfile/$eventId'),
        headers: await createHeaders()
        );
      if (response.statusCode == 200) {
        print("Profile updated");
      } else {
        print("Profile update failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}