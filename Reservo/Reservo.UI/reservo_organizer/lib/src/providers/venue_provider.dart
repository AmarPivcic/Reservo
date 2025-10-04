import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservo_organizer/src/models/search_result.dart';
import 'package:reservo_organizer/src/models/venue/venue.dart';
import 'package:reservo_organizer/src/models/venue_request/venue_request.dart';
import 'package:reservo_organizer/src/models/venue_request/venue_request_insert.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';

class VenueProvider extends BaseProvider<Venue, Venue> {
  
  VenueProvider() : super('Venue');

  List<Venue> venues= [];
  int countOfVenues = 0;
  bool isLoading = false;

  Future<void> getVenues(int? cityId, int? categoryId) async {
    isLoading = true;
    notifyListeners();

    final queryParams = {
      "CityId": cityId.toString(),
      "CategoryId": categoryId.toString()
    };
    try {
      SearchResult<Venue> searchResult = await get(
        filter: queryParams,
        fromJson: (json) => Venue.fromJson(json)
        );
      venues = searchResult.result;
      countOfVenues = searchResult.count;
      isLoading=false;
      notifyListeners();
    } catch (e) {
      venues = [];
      countOfVenues = 0;
      isLoading=false;
      notifyListeners();
    }
  }

  Future<VenueRequest> requestVenue(VenueRequestInsert requestData) async {
    final response = await http.post(
      Uri.parse("${BaseProvider.baseUrl}/VenueRequest"),
      headers: await createHeaders(),
      body: jsonEncode(requestData.toJson()),
    );

    if(response.statusCode == 200){
        final data = jsonDecode(response.body)as Map<String, dynamic>;
        return VenueRequest.fromJson(data);
    }else {
        throw Exception("Failed to create request");
    }
  }
}