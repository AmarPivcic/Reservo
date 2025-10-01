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
    print("Hit RATED");
    isLoading = true;
    notifyListeners();
    try {
      SearchResult<Event> searchResult = await get(
        fromJson: (json) => Event.fromJson(json),
        customEndpoint: 'GetByRating'
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
}