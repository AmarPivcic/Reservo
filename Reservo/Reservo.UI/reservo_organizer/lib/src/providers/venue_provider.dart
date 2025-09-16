import 'package:reservo_organizer/src/models/search_result.dart';
import 'package:reservo_organizer/src/models/venue/venue.dart';
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
}