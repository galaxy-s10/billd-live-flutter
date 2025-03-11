import 'dart:io';

import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:get/get.dart' as get_x;
import 'package:billd_live_flutter/stores/app.dart';
import 'package:dio/dio.dart';
import 'package:billd_live_flutter/utils/index.dart';

class HttpRequest {
  static BaseOptions baseOptions = BaseOptions(
      baseUrl: axiosBaseUrl,
      connectTimeout: const Duration(seconds: axiosTimeoutSeconds));
  static Dio dio = Dio(baseOptions);

  static Map<String, dynamic> getHeaders() {
    final Controller store = get_x.Get.find<Controller>();

    var env = -1;
    var app = -1;

    if (Platform.isAndroid) {
      env = clientEnvEnum['android'] ?? -1;
      app = clientAppEnum['billd_live_android_app'] ?? -1;
    } else if (Platform.isIOS) {
      env = clientEnvEnum['ios'] ?? -1;
      app = clientAppEnum['billd_live_ios_app'] ?? -1;
    }

    return {
      'Authorization': 'Bearer ${store.token}',
      'X-Clientenv': env,
      'X-Clientapp': app,
      'X-Clientappver': store.appInfo.value.version
    };
  }

  static Future get(url, {Map<String, dynamic>? params}) async {
    try {
      var resp = await dio.request(url,
          queryParameters: params,
          options: Options(method: 'get', headers: getHeaders()));
      return resp.data;
    } catch (e) {
      billdPrint('dio错误', e);
      rethrow;
    }
  }

  static Future post(url, {Map<String, dynamic>? data}) async {
    try {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
            // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。
            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            // 如果你想终止请求并触发一个错误，你可以使用 `handler.reject(error)`。
            billdPrint('====onResponse====');
            return handler.next(response);
          },
          onError: (DioException e, ErrorInterceptorHandler handler) {
            // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
            billdPrint('====onError====');
            handler.resolve(e.response!);
            // return handler.next(e);
          },
        ),
      );
      var resp = await dio.request(url,
          data: data, options: Options(method: 'post', headers: getHeaders()));
      return resp.data;
    } catch (e) {
      rethrow;
    }
  }
}
