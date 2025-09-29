import 'dart:convert';
import 'package:reservo_organizer/src/models/review/review.dart';
import 'package:reservo_organizer/src/providers/base_provider.dart';
import 'package:http/http.dart' as http;


class ReviewProvider extends BaseProvider<Review, Review>
{
  ReviewProvider() : super('Review');

  Future<List<Review>> getReviewsForEvent(int eventId) async {
    final response = await http.get(
      Uri.parse('${BaseProvider.baseUrl}/Review/EventReviews/$eventId'),
      headers: await createHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load review data");
    }
  }
}