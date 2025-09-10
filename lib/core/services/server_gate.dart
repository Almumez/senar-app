import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../../gen/locale_keys.g.dart';

import '../../models/user_model.dart';
import '../utils/enums.dart';
import '../utils/logger.dart';

class ServerGate {
final String _baseUrl = 'https://backend.senar.me/api';
//  final String _baseUrl = 'https://stage.senar.me/api';
  //final String _baseUrl = 'https://gas.azmy.aait-d.com/api';
 //final String _baseUrl = 'http://192.168.100.250:8000/api';
 //final String _baseUrl = 'http://192.168.0.116:8000/api';

  Map<String, dynamic> get constHeader => {
        if (UserModel.i.isAuth) "Authorization": "Bearer ${UserModel.i.token}",
        "Accept": "application/json",
        "Accept-Language": LocaleKeys.lang.tr(),
      };

  final _dio = Dio();

  ServerGate._() {
    _dio.interceptors.add(CustomApiInterceptor());
  }
  static final ServerGate i = ServerGate._();

  Future<CustomResponse> sendToServer<T>({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    Map<String, dynamic>? formData,
  }) async {
    try {
      params?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      headers?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      body?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      formData?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      final res = await _dio.post(
        url.startsWith('http') ? url : "$_baseUrl/$url",
        data: formData == null ? (body ?? {}) : FormData.fromMap(formData),
        options: Options(
          headers: {if (headers != null) ...headers, ...constHeader},
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );
      if ((res.statusCode ?? 404) < 300 && res.data is Map) {
        return CustomResponse<T>(
          success: true,
          data: res.data,
          msg: res.data?["message"] ?? "",
          statusCode: 200,
        );
      } else {
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 422,
          requestOptions: res.requestOptions,
          response: res,
        );
      }
    } on DioException catch (e) {
      return handleServerError(e);
    } catch (e) {
      return CustomResponse(
        success: false,
        statusCode: 422,
        errType: ErrorType.unknown,
        msg: kDebugMode ? '$e' : LocaleKeys.something_went_wrong_please_try_again.tr(),
      );
    }
  }

  Future<CustomResponse> deleteFromServer<T>({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    Map<String, dynamic>? formData,
  }) async {
    try {
      params?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      headers?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      body?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      formData?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      final res = await _dio.delete(
        url.startsWith('http') ? url : "$_baseUrl/$url",
        data: formData == null ? (body ?? {}) : FormData.fromMap(formData),
        options: Options(
          headers: {if (headers != null) ...headers, ...constHeader},
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );
      if (res.statusCode == 200 && res.data is Map) {
        return CustomResponse<T>(
          success: true,
          data: res.data,
          msg: res.data?["message"] ?? "",
          statusCode: 200,
        );
      } else {
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 422,
          requestOptions: res.requestOptions,
          response: res,
        );
      }
    } on DioException catch (e) {
      return handleServerError(e);
    } catch (e) {
      return CustomResponse(
        success: false,
        statusCode: 422,
        errType: ErrorType.unknown,
        msg: kDebugMode ? '$e' : LocaleKeys.something_went_wrong_please_try_again.tr(),
      );
    }
  }

  Future<CustomResponse> getFromServer<T>({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    CancelToken? cancelToken,
    bool constantHeaders = true,
  }) async {
    try {
      params?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      headers?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      final res = await _dio.get(
        url.startsWith('http') ? url : "$_baseUrl/$url",
        cancelToken: cancelToken,
        options: Options(
          headers: {if (headers != null) ...headers, if (constantHeaders) ...constHeader},
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );
      if (res.statusCode == 200 && res.data is Map) {
        return CustomResponse<T>(
          success: true,
          data: res.data,
          msg: res.data?["message"] ?? "",
          statusCode: 200,
        );
      } else {
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 422,
          requestOptions: res.requestOptions,
          response: res,
        );
      }
    } on DioException catch (e) {
      return handleServerError(e);
    } catch (e) {
      return CustomResponse(
        success: false,
        statusCode: 402,
        errType: ErrorType.unknown,
        msg: LocaleKeys.something_went_wrong_please_try_again.tr(),
      );
    }
  }

  Future<CustomResponse> putToServer<T>({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    Map<String, dynamic>? formData,
  }) async {
    try {
      params?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      headers?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      body?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      formData?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      final res = await _dio.put(
        url.startsWith('http') ? url : "$_baseUrl/$url",
        data: formData == null ? (body ?? {}) : FormData.fromMap(formData),
        options: Options(
          headers: {if (headers != null) ...headers, ...constHeader},
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );
      if (res.statusCode == 200 && res.data is Map) {
        return CustomResponse<T>(
          success: true,
          data: res.data,
          msg: res.data?["message"] ?? "",
          statusCode: 200,
        );
      } else {
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 422,
          requestOptions: res.requestOptions,
          response: res,
        );
      }
    } on DioException catch (e) {
      return handleServerError(e);
    } catch (e) {
      return CustomResponse(
        success: false,
        statusCode: 422,
        errType: ErrorType.unknown,
        msg: kDebugMode ? '$e' : LocaleKeys.something_went_wrong_please_try_again.tr(),
      );
    }
  }

  Future<CustomResponse> patchToServer<T>({
    required String url,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? body,
    Map<String, dynamic>? formData,
  }) async {
    try {
      params?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      headers?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      body?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      formData?.removeWhere((key, value) => value == null || '$value'.isEmpty);
      final res = await _dio.patch(
        url.startsWith('http') ? url : "$_baseUrl/$url",
        data: formData == null ? (body ?? {}) : FormData.fromMap(formData),
        options: Options(
          headers: {if (headers != null) ...headers, ...constHeader},
          responseType: ResponseType.json,
        ),
        queryParameters: params,
      );
      if (res.statusCode == 200 && res.data is Map) {
        return CustomResponse<T>(
          success: true,
          data: res.data,
          msg: res.data?["message"] ?? "",
          statusCode: 200,
        );
      } else {
        throw DioException.badResponse(
          statusCode: res.statusCode ?? 422,
          requestOptions: res.requestOptions,
          response: res,
        );
      }
    } on DioException catch (e) {
      return handleServerError(e);
    } catch (e) {
      return CustomResponse(
        success: false,
        statusCode: 422,
        errType: ErrorType.unknown,
        msg: kDebugMode ? '$e' : LocaleKeys.something_went_wrong_please_try_again.tr(),
      );
    }
  }

  CustomResponse<T> handleServerError<T>(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return CustomResponse(
        success: false,
        statusCode: err.response?.statusCode ?? 0,
        errType: ErrorType.canceled,
        msg: err.response?.data["message"] ?? '',
        data: err.response?.data,
      );
    } else if (err.type == DioExceptionType.badResponse) {
      if (err.response!.data.toString().contains("DOCTYPE") || err.response!.data.toString().contains("<script>") || err.response!.data["exception"] != null) {
        return CustomResponse(
          success: false,
          errType: ErrorType.server,
          statusCode: err.response!.statusCode ?? 500,
          msg: kDebugMode ? "${err.response!.data}" : LocaleKeys.something_went_wrong_please_try_again.tr(),
        );
      } else if (err.response?.statusCode == 401) {
        UserModel.i.clear();
        UserModel.i.save();
        return CustomResponse(
          success: false,
          statusCode: err.response?.statusCode ?? 401,
          errType: ErrorType.unAuth,
          msg: err.response?.data["message"] ?? '',
          data: err.response?.data,
        );
      } else {
        return CustomResponse(
          success: false,
          statusCode: err.response?.statusCode ?? 500,
          errType: ErrorType.backEndValidation,
          msg: err.response?.data["message"] ?? "",
          data: err.response?.data,
        );
      }
    } else if (err.type == DioExceptionType.receiveTimeout || err.type == DioExceptionType.sendTimeout) {
      return CustomResponse(
        success: false,
        statusCode: err.response?.statusCode ?? 500,
        errType: ErrorType.network,
        msg: LocaleKeys.poor_connection_check_the_quality_of_the_internet.tr(),
        data: err.response?.data,
      );
    } else if (err.response == null) {
      return CustomResponse(
        success: false,
        statusCode: 402,
        errType: ErrorType.network,
        msg: LocaleKeys.please_check_your_internet_connection.tr(),
        data: err.response?.data,
      );
    } else {
      return CustomResponse(
        success: false,
        statusCode: 402,
        errType: ErrorType.unknown,
        msg: LocaleKeys.something_went_wrong_please_try_again.tr(),
        data: err.response?.data,
      );
    }
  }
}

class CustomApiInterceptor extends Interceptor {
  final log = LoggerDebug(headColor: LogColors.red, constTitle: "Server Gate Logger");
  CustomApiInterceptor();
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.red("\x1B[37m====== ERROR RESPONSE (${err.response?.statusCode}) ======\x1B[0m");
    log.red("\x1B[31mURL: ${err.requestOptions.uri}\x1B[0m");
    log.red("\x1B[31mMethod: ${err.requestOptions.method}\x1B[0m");
    log.red("\x1B[31mError Message: ${err.message}\x1B[0m");
    log.red("\x1B[31mError Data: ${jsonEncode(err.response?.data ?? {})}\x1B[0m");
    log.red("\x1B[31mRequest Headers: ${jsonEncode(err.requestOptions.headers)}\x1B[0m");
    log.red("\x1B[31mRequest Body: ${_formatRequestBody(err.requestOptions.data)}\x1B[0m");
    log.white("cURL Command: ${_generateCurlCommand(err.requestOptions)}");
    return super.onError(err, handler);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    log.green("====== RESPONSE SUCCESS (${response.statusCode}) ======");
    log.green("URL: ${response.requestOptions.uri}");
    log.green("Method: ${response.requestOptions.method}");
    log.green("Response Time: ${response.requestOptions.receiveTimeout != null ? '${response.requestOptions.receiveTimeout}ms' : 'N/A'}");
    log.green("Response Data: ${jsonEncode(response.data)}");
    log.white("cURL Command: ${_generateCurlCommand(response.requestOptions)}");
    return super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.yellow("====== REQUEST STARTED ======");
    log.yellow("URL: ${options.uri}");
    log.yellow("Method: ${options.method}");
    
    if (options.data != null) {
      log.cyan("Request Body:");
      log.cyan(_formatRequestBody(options.data));
    }
    
    if (options.queryParameters.isNotEmpty) {
      log.white("Query Parameters:");
      log.white(jsonEncode(options.queryParameters));
    }
    
    log.yellow("Request Headers:");
    log.yellow(jsonEncode(options.headers));
    return super.onRequest(options, handler);
  }

  String _formatRequestBody(dynamic data) {
    if (data == null) return "null";
    
    try {
      if (data is FormData) {
        Map<String, dynamic> body = {};
        data.fields.forEach((element) {
          body[element.key] = '${element.value}';
        });
        
        // Add files info
        if (data.files.isNotEmpty) {
          body['__files__'] = data.files.map((file) => 
            {'key': file.key, 'filename': file.value.filename}).toList();
        }
        
        return jsonEncode(body);
      } else if (data is Map) {
        return jsonEncode(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return "Error formatting request body: $e";
    }
  }

  String _generateCurlCommand(RequestOptions options) {
    final method = options.method;
    final url = options.uri.toString();
    final headers = options.headers;
    final data = options.data;

    // Start building the cURL command
    final curlCommand = StringBuffer("curl -X $method '$url'");

    // Add headers
    headers.forEach((key, value) {
      curlCommand.write(" -H '$key: $value'");
    });

    // Add body if present
    if (data != null) {
      if (data is FormData) {
        final formDataMap = {
          for (var entry in data.fields) entry.key: entry.value,
          for (var file in data.files) file.key: file.value.filename,
        };
        curlCommand.write(" --data '${jsonEncode(formDataMap)}'");
      } else if (data is Map) {
        curlCommand.write(" --data '${jsonEncode(data)}'");
      } else {
        curlCommand.write(" --data '$data'");
      }
    }

    return curlCommand.toString();
  }
}

class CustomResponse<T> {
  bool success;
  ErrorType errType;
  String msg;
  int statusCode;
  T? data;

  CustomResponse({
    this.success = false,
    this.errType = ErrorType.none,
    this.msg = "",
    this.statusCode = 0,
    this.data,
  });
}
