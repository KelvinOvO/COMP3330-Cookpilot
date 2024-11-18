// create a photo service that return a image url from a keyword utilizing Bing API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PhotoService {
  static final String? apiKey = dotenv.env['BING_IMAGE_SEARCH_API_KEY'];
  static final String searchUrl = 'https://api.bing.microsoft.com/v7.0/images/search';

  static Future<String> fetchImageUrl(String keyword) async {
    final headers = {
      'Ocp-Apim-Subscription-Key': apiKey ?? (throw Exception('Missing required environment variable: BING_IMAGE_SEARCH_API_KEY')),
    };


    final params = {
      "q": keyword,
      "license": "public", // Optional: filter by license type
      "imageType": "photo", // Optional: filter by image type
      "count": "1",        // Number of results to return
      "offset": "0",        // Pagination offset
      "mkt": "en-US",       // Market (optional)
      "safeSearch": "Moderate" // Safe search level (optional)
    };

    // Make the GET request
    final response = await http.get(
      Uri.parse('$searchUrl?${Uri(queryParameters: params).query}'),
      headers: headers,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Extract image URLs from the response
      return jsonResponse['value']['contentUrl'];

    } else {
      throw Exception('Failed to load images: ${response.statusCode}');
    }
  }


}