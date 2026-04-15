import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(
            milliseconds: AppConstants.connectionTimeout,
          ),
          receiveTimeout: const Duration(
            milliseconds: AppConstants.receiveTimeout,
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.accessTokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            // TODO: Implement token refresh logic
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: AppConstants.errorNetwork);

      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return ValidationFailure(
              message:
                  error.response?.data['message'] ?? AppConstants.errorGeneric,
            );
          case 401:
            return AuthFailure(
              message: AppConstants.errorUnauthorized,
              statusCode: 401,
            );
          case 403:
            return ForbiddenFailure(message: AppConstants.errorForbidden);
          case 404:
            return NotFoundFailure(message: AppConstants.errorNotFound);
          default:
            return ServerFailure(
              message:
                  error.response?.data['message'] ?? AppConstants.errorGeneric,
              statusCode: error.response?.statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Requête annulée');

      default:
        return const UnknownFailure(message: AppConstants.errorGeneric);
    }
  }
}
