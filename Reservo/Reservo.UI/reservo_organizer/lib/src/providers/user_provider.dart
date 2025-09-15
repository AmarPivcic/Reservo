import 'dart:convert';
import 'package:reservo_organizer/src/models/user/user.dart';
import 'package:reservo_organizer/src/models/user/user_update.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User, User>
{
  UserProvider() : super('User');

  Future<User> updateUser(UserUpdate dto) async {
   try {
     final response = await http.put(
        Uri.parse('${BaseProvider.baseUrl}/User/UpdateByToken'),
        headers: await createHeaders(),
        body: jsonEncode(dto.toJson())
      );

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
     try {
     final response = await http.get(
        Uri.parse('${BaseProvider.baseUrl}/User/GetCurrentUser'),
        headers: await createHeaders(),
      );
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
}