import 'package:reservo_admin/src/models/city/city.dart';
import 'package:reservo_admin/src/models/search_result.dart';
import 'package:reservo_admin/src/providers/base_provider.dart';

import '../models/city/city_insert.dart';


class CityProvider extends BaseProvider<City, CityInsert> {

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
        customEndpoint: 'GetAllCities'
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

  Future<String> insertCity(CityInsert data) async {
    try {
      await insert(data, toJson: (d) => d.toJson());
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteCity(int cityId) async {
    try {
      await delete(id: cityId, customEndpoint: 'DeleteCity');
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> editCity(int cityId, CityInsert data) async {
    try {
      await update(id: cityId, item: data, toJson: (d) => d.toJson());
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }
}