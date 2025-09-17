import 'package:reservo_client/src/models/city/city.dart';
import 'package:reservo_client/src/models/search_result.dart';
import 'package:reservo_client/src/providers/base_provider.dart';

class CityProvider extends BaseProvider<City, City> {

  List<City> cities = [];
  int countOfCiteis = 0;
  bool isLoading = false;

  CityProvider() : super('City');

  Future<void> getCities() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<City> searchResult = await get(
        fromJson: (json) => City.fromJson(json),
        );
      cities = searchResult.result;
      countOfCiteis = searchResult.count;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      cities = [];
      countOfCiteis = 0;
      isLoading = false;
      notifyListeners();
    }
  }
}