import 'dart:convert';
import 'package:reservo_admin/src/models/user/user.dart';
import 'package:reservo_admin/src/models/user/user_update.dart';
import 'package:reservo_admin/src/models/user/user_update_password.dart';
import 'package:reservo_admin/src/providers/base_provider.dart';
import 'package:reservo_admin/src/utilities/custom_exception.dart';
import 'package:http/http.dart' as http;

import '../models/search_result.dart';


class UserProvider extends BaseProvider<User, User>
{
  UserProvider() : super('User');

  bool isLoading = false;
  List<User> users= [];
  int countOfUsers = 0;


  Future<void> getActiveUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<User> searchResult = await get(
        fromJson: (json) => User.fromJson(json),
        customEndpoint: "GetActiveUsers"
        );
      users = searchResult.result;
      countOfUsers = searchResult.count;
      isLoading=false;
      notifyListeners();
    } catch (e) {
      users = [];
      countOfUsers = 0;
      isLoading=false;
      notifyListeners();
    }
  }

  Future<void> getInactiveUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<User> searchResult = await get(
        fromJson: (json) => User.fromJson(json),
        customEndpoint: "GetInactiveUsers"
        );
      users = searchResult.result;
      countOfUsers = searchResult.count;
      isLoading=false;
      notifyListeners();
    } catch (e) {
      users = [];
      countOfUsers = 0;
      isLoading=false;
      notifyListeners();
    }
  }

  Future<void> getPendingOrganizers() async {
    isLoading = true;
    notifyListeners();

    try {
      SearchResult<User> searchResult = await get(
        fromJson: (json) => User.fromJson(json),
        customEndpoint: "GetPendingOrganizers"
        );
      users = searchResult.result;
      countOfUsers = searchResult.count;
      isLoading=false;
      notifyListeners();
    } catch (e) {
      users = [];
      countOfUsers = 0;
      isLoading=false;
      notifyListeners();
    }
  }

  Future<User> updateUser(UserUpdate dto) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.put(
          Uri.parse('${BaseProvider.baseUrl}/User/UpdateByToken'),
          headers: await createHeaders(),
          body: jsonEncode(dto.toJson())
        );

        isLoading = false;
        notifyListeners();

        if(response.statusCode == 200){
          final data = jsonDecode(response.body);
          return User.fromJson(data);
        }
        else {
          throw Exception("Failed to update user. Status: ${response.statusCode}");
        }
    } catch (e) {
      throw Exception("Error updating user: $e");
    }
  }

  Future<User> getCurrentUser() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('${BaseProvider.baseUrl}/User/GetCurrentUser'),
        headers: await createHeaders(),
      );
      isLoading = false;
      notifyListeners();
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      else {
        throw Exception("Failed to fetch current user. Status: ${response.statusCode}");
      }
    } catch (e) {
     throw Exception("Error fetching user: $e");
    }
  }

  Future changePassword(UserUpdatePassword dto) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseProvider.baseUrl}/User/UpdatePasswordByToken'),
        headers: await createHeaders(),
        body: jsonEncode(dto.toJson())
      );

      if(response.statusCode == 200){
        return null;
      }

      else {
        handleHttpError(response);
        throw Exception('Change failed');
      }

    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("$e");
    }
  }

  Future<void> changeActiveStatus(int id, {required bool showActive}) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseProvider.baseUrl}/User/ChangeActiveStatus?id=$id'),
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        if (showActive) {
          await getActiveUsers();
        } else {
          await getInactiveUsers();
        }
      } else {
        throw Exception("Failed to change status. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error changing status: $e");
    }
  }

  Future<void> activateOrganizer(int id) async {
    try {
      final response = await http.put(
        Uri.parse('${BaseProvider.baseUrl}/User/ActivateOrganizer?id=$id'),
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
          await getPendingOrganizers();
      } else {
        throw Exception("Failed to change status. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error changing status: $e");
    }
  }

}