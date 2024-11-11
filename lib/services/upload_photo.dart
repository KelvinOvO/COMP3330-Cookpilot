import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadPhotoService {
  // Configuration
  static const String apiKey = """OBOqZ4gLpSY1xWIyl81HSpx6gTbWy2UVhYh4dtabFIgc1TvSXELDJQQJ99AKACMsfrFXJ3w3AAABACOGMmB5""";
  // static const String imagePath =
  //     r"C:\Users\Ray\Downloads\360_F_520381745_vlNJ8dxbe9p5jJ7zsKd9QnKniru9IMiG.jpg";
  static void callMainFunction(String imagePath) {
    main(imagePath);
  }

  static Future<void> main(String imagePath) async {
    final encodedImage = base64Encode(File(imagePath).readAsBytesSync());
    final headers = {
      "Content-Type": "application/json",
      "api-key": apiKey,
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
              """You are an AI assistant that analyzes images 
              provided by the user to identify food ingredients. 
              For each ingredient detected in the image, 
              return a JSON object that includes the ingredient name and its count. 
              The JSON structure should look like this:
              \n\n{\n  \"ingredients\": [\n    {\n      \"name\": \"ingredient_name_1\",\n      \"count\": ingredient_count_1\n    },\n    {\n      \"name\": \"ingredient_name_2\",\n      \"count\": ingredient_count_2\n    }\n  ]\n}\n\n
              For example, if the image contains 2 tomatoes and 3 onions, 
              the output should be:
              \n\n{\n  \"ingredients\": [\n    {\n      \"name\": \"tomato\",\n      \"count\": 2\n    },\n    {\n      \"name\": \"onion\",\n      \"count\": 3\n    }\n  ]\n}\n
              Please analyze the provided image and return the ingredients in the specified format.
               This prompt clearly defines the task, specifies the desired output format,
                and provides an example to guide the model's response."""

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

    const String endpoint  =
        "https://khrwo-m38f73pc-westus3.openai.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2024-02-15-preview";

    // Send request
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(payload),
      );
      // log("1");
      if (response.statusCode != 200) {
        throw Exception("Failed to make the request. Error: ${response.reasonPhrase}");
      }

      // Handle the response as needed (e.g., print or process)
      final responseData = jsonDecode(response.body)["choices"][0]["message"]["content"];
     // log(responseData);
      Map<String, dynamic> data = json.decode(response.body);
      // Access the 'ingredients' list
      String messageContent = data['choices'][0]['message']['content'];
      // Parse the content in the 'message' field
      Map<String, dynamic> messageData = json.decode(messageContent);
      // Access the 'ingredients' list
      List<dynamic> ingredients = messageData['ingredients'];
      // Loop through the ingredients and print name and count
      for (var ingredient in ingredients) {
        String name = ingredient['name'];
        int count = ingredient['count'];
        log('$name: $count');
      }
      log("4");
      //Save the response to a JSON file
      // var currentFilePath = Platform.script.toFilePath();
      // var parentDirectoryPath = Directory(currentFilePath).parent.path;
      // print(currentFilePath);
      // print(parentDirectoryPath);
      // var fileName = 'response.json';
      // // var filePath = '$parentDirectoryPath/json/$fileName';
      // var filePath = '/json/$fileName';
      //
      // print(filePath);
      // File file = File(filePath);
      //
      // if (file.existsSync()) {
      //   print('File found!');
      //   // Perform operations on the file
      // } else {
      //   print('File not found.');
      // }
      // final file = File("/response.json");
      // await file.writeAsString(responseData);
      log("5");
    } catch (e) {
      log("upload photo Error: $e");
    }
  }
}