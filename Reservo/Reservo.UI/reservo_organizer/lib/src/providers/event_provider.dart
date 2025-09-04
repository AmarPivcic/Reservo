import 'dart:async';

import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/models/search_result.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';

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

}