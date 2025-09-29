import 'dart:convert';
import 'package:reservo_client/src/models/review/review.dart';
import 'package:reservo_client/src/models/review/review_insert.dart';
import 'package:reservo_client/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:reservo_client/src/utilities/custom_exception.dart';


class ReviewProvider extends BaseProvider<Review, ReviewInsert>
{
  ReviewProvider() : super('Review');

  Future<Review?> getReviewForOrder(int orderId) async {
  final response = await http.get(
    Uri.parse('${BaseProvider.baseUrl}/Review/OrderReview/$orderId'),
    headers: await createHeaders(),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data != null && data is Map<String, dynamic> && data.isNotEmpty) {
      return Review.fromJson(data);
    }

    return null;
  } else if (response.statusCode == 204) {
    return null; 
  } else {
    throw Exception("Failed to load review data");
  }
}

  Future<void> deleteReview(int reviewId) async {
    try {
      final response = await http.delete(
        Uri.parse('${BaseProvider.baseUrl}/Review/$reviewId'),
        headers: await createHeaders(),
      );
      
      if(response.statusCode == 200) {
        return;
      }
      else {
        handleHttpError(response);
        throw Exception('Delete failed');
      }
    } on CustomException {
      rethrow;
    } catch (e) { 
      throw CustomException("Can't reach the server. Please check your connection.");
    }
  }

  Future<Review> createReview(int id, int eventId, int rating, String comment) async {
    final reviewInsert = ReviewInsert(
      comment: comment,
      rating: rating,
      eventId: eventId
    );

    final response = await http.post(
      Uri.parse('${BaseProvider.baseUrl}/Review/InsertReview'),
      headers: await createHeaders(),
      body: jsonEncode(reviewInsert.toJson())
    );

    if(response.statusCode == 200)
    {
      final data = jsonDecode(response.body)as Map<String, dynamic>;
      return Review.fromJson(data);
    }else {
      throw Exception("Failed to insert review");
    }
  }
}