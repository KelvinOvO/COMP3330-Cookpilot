// lib/global/app_controller.dart
import 'package:app_controller_client/app_controller_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late AppControllerClient appController;

void init() {
  final baseUrl = dotenv.env['APP_CONTROLLER_BASE_URL'];
  final accessToken = dotenv.env['APP_CONTROLLER_ACCESS_TOKEN'];

  if (baseUrl == null || accessToken == null) {
    throw Exception('Missing required environment variables');
  }

  appController = AppControllerClient(
    dio: Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 60),
    )),
  );

  appController.setBearerAuth('Bearer', accessToken);
}