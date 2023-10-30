import 'package:dio/dio.dart';

// const baseUrl = 'https://api.hsslive.cn/prodapi/';
const baseUrl = 'https://live-api.hsslive.cn';
const timeout = 5;

class HttpRequest {
  static BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(seconds: timeout), baseUrl: baseUrl);
  static Dio dio = Dio(baseOptions);

  static Future get(url, {Map<String, dynamic>? params}) async {
    try {
      var resp = await dio.request(url,
          queryParameters: params,
          options: Options(
            method: 'get',
          ));
      return resp;
    } catch (e) {
      rethrow;
    }
  }
}
