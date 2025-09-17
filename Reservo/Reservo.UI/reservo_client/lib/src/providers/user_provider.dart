import 'dart:convert';
import 'package:reservo_client/src/models/user/user.dart';
import 'package:reservo_client/src/models/user/user_update.dart';
import 'package:reservo_client/src/models/user/user_update_password.dart';
import 'package:reservo_client/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_client/src/utilities/custom_exception.dart';

class UserProvider extends BaseProvider<User, User>
{
  UserProvider() : super('User');

  bool isLoading = false;

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
}