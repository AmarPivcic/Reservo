import 'package:reservo_admin/src/models/search_result.dart';
import 'package:reservo_admin/src/models/venue_request/venue_request.dart';
import 'package:reservo_admin/src/models/venue_request/venue_request_insert.dart';
import 'package:reservo_admin/src/providers/base_provider.dart';


class VenueRequestProvider extends BaseProvider<VenueRequest, VenueRequestInsert> {
  
  VenueRequestProvider() : super('VenueRequest');

  List<VenueRequest> venueRequests= [];
  int countOfVenueRequests = 0;
  bool isLoading = false;

  Future<void> getVenueRequests() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<VenueRequest> searchResult = await get(
        fromJson: (json) => VenueRequest.fromJson(json),

        );
      venueRequests = searchResult.result;
      countOfVenueRequests = searchResult.count;
      isLoading=false;
      notifyListeners();
    } catch (e) {
      venueRequests = [];
      countOfVenueRequests = 0;
      isLoading=false;
      notifyListeners();
    }
  }

  Future<void> updateVenue(int id, VenueRequestInsert dto) async {
    await update(id: id, item: dto, toJson: (d) => d.toJson());
    await getVenueRequests();
  }

}