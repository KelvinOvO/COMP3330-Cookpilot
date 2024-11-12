// lib/services/upload_photo.dart
import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadPhotoService {
  static final String? apiKey = dotenv.env['AZURE_OPENAI_API_KEY'];

  static Future<List<Map<String, dynamic>>> callMainFunction(String imagePath) {
    return main(imagePath);
  }

  static Future<List<Map<String, dynamic>>> main(String imagePath) async {
    final encodedImage = base64Encode(File(imagePath).readAsBytesSync());
    final headers = {
      "Content-Type": "application/json",
      "api-key": apiKey ?? (throw Exception('Missing required environment variable: AZURE_OPENAI_API_KEY')),
    };

    // Payload for the request
    final payload = {
      "messages": [
        {
          "role": "system",
          "content": [
            {
              "type": "text",
              "text":
              """You are an AI assistant that analyzes images provided by the user to identify food ingredients. For each ingredient detected in the image, return an array of objects in JSON format. Each object should include the following properties:
name: The name of the ingredient.
calories: The calorie content per 100g of the ingredient.
protein: The protein content per 100g of the ingredient.
fat: The fat content per 100g of the ingredient.
carbs: The carbohydrate content per 100g of the ingredient.
freshness: A description of the ingredient's freshness (e.g., 'Fresh', 'Stale').
suggestions: An array of suggestions for using the ingredient.

The JSON structure should look like this:
  [
    {
     "name": "ingredient_name_1",
     "calories": ingredient_calories_1,
     "protein": ingredient_protein_1,
     "fat": ingredient_fat_1,
     "carbs": ingredient_carbs_1,
     "freshness": "ingredient_freshness_1",
     "suggestions": ["suggestion_1", "suggestion_2", "suggestion_3"]
    },
    {
     "name": "ingredient_name_2",
     "calories": ingredient_calories_2,
     "protein": ingredient_protein_2,
     "fat": ingredient_fat_2,
     "carbs": ingredient_carbs_2,
     "freshness": "ingredient_freshness_2",
     "suggestions": ["suggestion_1", "suggestion_2", "suggestion_3"]
    }
  ]

For example, if the image contains an apple and a chicken breast, the output should be:
  [
    {
     "name": "Apple",
     "calories": 52,
     "protein": 0.3,
     "fat": 0.2,
     "carbs": 14,
     "freshness": "Fresh",
     "suggestions": ["Can make apple pie", "Recommend refrigeration", "Suitable for raw consumption"]
    },
    {
     "name": "Chicken",
     "calories": 165,
     "protein": 31,
     "fat": 3.6,
     "carbs": 0,
     "freshness": "Fresh",
     "suggestions": ["Can be grilled, fried, or sautéed", "Recommend freezing", "Suitable for various cooking methods"]
    }
  ]"""

            }
          ]
        },
        {
          "role": "user",
          "content": [
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$encodedImage"}
            },
          ]
        }
      ],
      "temperature": 0.7,
      "top_p": 0.95,
      "max_tokens": 2059
    };

    final String? endpoint = dotenv.env['AZURE_OPENAI_API_URL'];
    if (endpoint == null) {
      throw Exception('Missing required environment variable: AZURE_OPENAI_API_URL');
    }

    // Send request
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to make the request. Error: ${response.reasonPhrase}");
      }

      final responseData = jsonDecode(response.body)["choices"][0]["message"]["content"];
      log(responseData);
      var data = responseData.replaceAll("```json", "").replaceAll("```", "");
      log (data);
      try {
        List<dynamic> jsonResponse = json.decode(data);
        List<Map<String, dynamic>> message = jsonResponse.cast<Map<String, dynamic>>();
        print(message);
        return(message);
      } catch (e) {
        print("Error decoding message content: $e");
      }

    } catch (e) {
      log("upload photo Error: $e");
    }

    final List<Map<String, dynamic>> mockIngredients = [
      {
        'name': 'Apple',
        'calories': 52,
        'protein': 0.3,
        'fat': 0.2,
        'carbs': 14,
        'freshness': 'Fresh',
        'suggestions': ['Can make apple pie', 'Recommend refrigeration', 'Suitable for raw consumption']
      },
      {
        'name': 'Chicken',
        'calories': 165,
        'protein': 31,
        'fat': 3.6,
        'carbs': 0,
        'freshness': 'Fresh',
        'suggestions': ['Can be grilled, fried, or sautéed', 'Recommend freezing', 'Suitable for various cooking methods']
      },
      {
        'name': 'Tomato',
        'calories': 18,
        'protein': 0.9,
        'fat': 0.2,
        'carbs': 3.9,
        'freshness': 'Fresh',
        'suggestions': ['Can make salads', 'Room temperature storage', 'Suitable for raw or cooked']
      },
      {
        'name': 'Salmon',
        'calories': 208,
        'protein': 22,
        'fat': 13,
        'carbs': 0,
        'freshness': 'Fresh',
        'suggestions': ['Recommended for sashimi', 'Keep refrigerated', 'Suitable for grilling']
      },
      {
        'name': 'Carrot',
        'calories': 41,
        'protein': 0.9,
        'fat': 0.2,
        'carbs': 10,
        'freshness': 'Fresh',
        'suggestions': ['Can make salads', 'Keep refrigerated', 'Suitable for raw or cooked']
      }
    ];
    return mockIngredients;
  }
}