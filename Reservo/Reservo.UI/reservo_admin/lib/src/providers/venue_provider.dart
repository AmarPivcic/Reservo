import 'package:reservo_admin/src/models/search_result.dart';
import 'package:reservo_admin/src/models/venue/venue.dart';
import 'package:reservo_admin/src/models/venue/venue_insert_update.dart';
import 'package:reservo_admin/src/providers/base_provider.dart';


class VenueProvider extends BaseProvider<Venue, VenueInsertUpdate> {
  
  VenueProvider() : super('Venue');

  List<Venue> venues= [];
  int countOfVenues = 0;
  bool isLoading = false;

  Future<void> getVenues() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<Venue> searchResult = await get(
        fromJson: (json) => Venue.fromJson(json),
        customEndpoint: 'GetAllVenues'
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


  Future<String> insertVenue(VenueInsertUpdate dto) async {
    try {
      await insert(dto, toJson: (d) => d.toJson());
      await getVenues();
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> updateVenue(int id, VenueInsertUpdate dto) async {
    try {
      await update(id: id, item: dto, toJson: (d) => d.toJson());
      await getVenues();
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteVenue(int id) async {
    try {
      await delete(id: id, customEndpoint: 'DeleteVenue');
      await getVenues();
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

}