import 'package:reservo_admin/src/models/category/category_insert.dart';
import 'package:reservo_admin/src/models/search_result.dart';
import 'package:reservo_admin/src/providers/base_provider.dart';
import '../models/category/category.dart';

class CategoryProvider extends BaseProvider<Category, CategoryInsert>
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

  Future<String> insertCategory(CategoryInsert data) async {
    try {
      await insert(data, toJson: (d) => d.toJson());
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteCategory(int categoryId) async {
    try {
      await delete(id: categoryId, customEndpoint: 'DeleteCategory');
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> updateCategory(int categoryId, CategoryInsert data) async {
    try {
      await update(id: categoryId, item: data, toJson: (d) => d.toJson());
      return "OK";
    } catch (e) {
      return e.toString();
    }
  }
}