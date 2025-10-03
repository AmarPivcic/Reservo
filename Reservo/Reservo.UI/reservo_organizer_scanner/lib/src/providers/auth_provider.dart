import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservo_organizer_scanner/src/providers/base_provider.dart';
import 'package:reservo_organizer_scanner/src/utilities/custom_exception.dart';

class AuthProvider extends BaseProvider<AuthProvider, AuthProvider> 
{
  AuthProvider() : super('Auth');

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BaseProvider.baseUrl}/login'),
        headers: <String,String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String> {
        'username': username, 
        'password': password,
        'role': 'Organizer'
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final token = data['token']; // only the token, not the whole JSON
        await storage.write(key: 'jwt_token', value: token);
        isLoggedIn = true;
      }else {
        handleHttpError(response);
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${BaseProvider.baseUrl}/logout'),
        headers: await createHeaders(),
      );

      if(response.statusCode == 200) {
        await storage.write(key: 'jwt_token', value: '');
        isLoggedIn = false;
      }
      else {
        handleHttpError(response);
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

}