import 'package:reservo_client/src/models/category/category.dart';
import 'package:reservo_client/src/models/search_result.dart';
import 'package:reservo_client/src/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category, Category>
{
  List<Category> categories = [];
  int countOfCategories = 0;
  bool isLoading = false;
  
  CategoryProvider() :super('Category');

  Future<void> getCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<Category> searchResult = await get(
        fromJson: (json) => Category.fromJson(json),
        );
        categories = searchResult.result;
        countOfCategories = searchResult.count;
        isLoading = false;
        notifyListeners();
      }
     catch (e) {
      categories = [];
        countOfCategories = 0;
        isLoading = false;
        notifyListeners();
    }
  }
}