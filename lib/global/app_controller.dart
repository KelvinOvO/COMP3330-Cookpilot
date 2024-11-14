// lib/global/app_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_controller_client/app_controller_client.dart';
import 'package:built_value/serializer.dart';
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

extension AppControllerClientExtensions on AppControllerClient {
  /// Get RecipeSearchStreamApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RecipeSearchStreamApi getRecipeSearchStreamApi() {
    return RecipeSearchStreamApi(dio, this.serializers);
  }
}

class RecipeSearchStreamApi {

  final Dio _dio;

  final Serializers _serializers;

  const RecipeSearchStreamApi(this._dio, this._serializers);

  /// Chat about a specific recipe with streaming response.
  ///
  ///
  /// Parameters:
  /// * [chatByRecipePostRequestModel]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Stream] of [RecipeSearchChatByRecipeStreamPost200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Stream<RecipeSearchChatByRecipeStreamPost200Response>>> recipeSearchChatByRecipeStreamPost({
    ChatByRecipePostRequestModel? chatByRecipePostRequestModel,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/RecipeSearch/ChatByRecipe/Stream';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'Bearer',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
      responseType: ResponseType.stream,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(ChatByRecipePostRequestModel);
      _bodyData = chatByRecipePostRequestModel == null ? null : _serializers.serialize(chatByRecipePostRequestModel, specifiedType: _type);

    } catch(error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<ResponseBody>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Stream<RecipeSearchChatByRecipeStreamPost200Response>? _responseData;

    try {
      _responseData = _response.data?.stream.transform(
        StreamTransformer.fromHandlers(
          handleData: (Uint8List data, EventSink<String> sink) {
            sink.add(utf8.decode(data));
          },
        ),
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: (String data, EventSink<String> sink) {
            LineSplitter.split(data).forEach(sink.add);
          },
        ),
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: (String data, EventSink<RecipeSearchChatByRecipeStreamPost200Response> sink) {
            final _data = _serializers.deserialize(
              json.decode(data),
              specifiedType: const FullType(RecipeSearchChatByRecipeStreamPost200Response),
            ) as RecipeSearchChatByRecipeStreamPost200Response;
            sink.add(_data);
          },
        ),
      );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Stream<RecipeSearchChatByRecipeStreamPost200Response>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}