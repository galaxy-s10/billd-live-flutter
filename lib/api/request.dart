import 'package:dio/dio.dart';

// const baseUrl = 'https://api.hsslive.cn/prodapi/';
const baseUrl = 'https://live-api.hsslive.cn';
const timeout = 5;

class HttpRequest {
  static BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(seconds: timeout), baseUrl: baseUrl);
  static Dio dio = Dio(baseOptions);

  static Future<Response> get() async {
    try {
      Response resp =
          await dio.request('/live/list', options: Options(method: 'get'));
      return resp;
    } catch (e) {
      rethrow;
    }
  }
}
