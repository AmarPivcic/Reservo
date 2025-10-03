import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_admin/src/models/search_result.dart';
import 'package:reservo_admin/src/utilities/custom_exception.dart';


abstract class BaseProvider<T, TInsertUpdate> with ChangeNotifier {
  
  static const String baseUrl = 'http://localhost:5113';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final String endpoint;

  BaseProvider(this.endpoint);

  Future<Map<String, String>> createHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<SearchResult<T>> get({
    String customEndpoint = '',
    Map<String, dynamic>? filter,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      String queryString =
          filter != null ? Uri(queryParameters: filter).query : '';
      String url =
          '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await http.get(
        Uri.parse(url),
        headers: await createHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        List<T> results =
            (data['result'] as List).map((item) => fromJson(item)).toList();

        return SearchResult<T>(
          count: data['count'],
          result: results,
        );
      } else {
        handleHttpError(response);
        throw CustomException('Unhandled HTTP error');
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(
          "Can't reach the server. Please check your internet connection.");
    }
  }

  Future<void> insert(
    TInsertUpdate item,
    {String customEndpoint = '',
    required Map<String, dynamic> Function(TInsertUpdate) toJson}) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}'),
        headers: await createHeaders(),
        body: jsonEncode(item),
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(
          "Can't reach the server. Please check your internet connection. $e");
    }
  }

  Future<T> insertResponse<T, TInsertUpdate>(
    TInsertUpdate item, {
    String customEndpoint = '',
    required Map<String, dynamic> Function(TInsertUpdate) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}'),
        headers: await createHeaders(),
        body: jsonEncode(toJson(item)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final created = fromJson(data);
        notifyListeners();
        return created;
      } else {
        handleHttpError(response);
        throw Exception("Insert failed");
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(
          "Can't reach the server. Please check your internet connection. $e");
    }
  }

  Future<void> update(
      {required int id,
      required TInsertUpdate item,
      required Map<String, dynamic> Function(TInsertUpdate) toJson,
      String customEndpoint = ''}) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}/$id'),
        headers: await createHeaders(),
        body: jsonEncode(toJson(item)),
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(
          "Can't reach the server. Please check your internet connection.");
    }
  }

  Future<void> delete({required int id, String customEndpoint = ''}) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/$endpoint${customEndpoint.isNotEmpty ? '/$customEndpoint' : ''}/$id'),
        headers: await createHeaders(),
      );
      if (response.statusCode == 200) {
        notifyListeners();
      } else {
        handleHttpError(response);
      }
    } on CustomException {
      rethrow;
    } catch (e) {
      throw CustomException(
          "Can't reach the server. Please check your internet connection.");
    }
  }

  void handleHttpError(http.Response response) {
    if (response.statusCode != 200) {
      String errorMessage = 'Unknown error. Status code: ${response.statusCode}';

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded['errors'] != null) {
            final errors = decoded['errors'];
            if (errors is Map<String, dynamic>) {
              final allErrors = errors.values
                  .expand((e) => e is List ? e : [e])
                  .join(', ');
              if (allErrors.isNotEmpty) errorMessage = allErrors;
            }
          }
          else if (decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        }
        else if (decoded is String) {
          errorMessage = decoded;
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      throw CustomException(errorMessage);
    }
  }
}