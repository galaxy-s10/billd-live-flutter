import 'package:dio/dio.dart';

const baseUrl = 'https://live-api.hsslive.cn';
const timeout = 1000 * 5;

class HttpRequest {
  static BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(milliseconds: timeout), baseUrl: baseUrl);
  static Dio dio = Dio(baseOptions);

  static get(String url,
      {String method = 'get', required Map<String, dynamic> params}) async {
    print('3333,$url,$params');
    try {
      Response response = await dio.request(
        url,
        queryParameters: params,
      );
      print(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static post(String url, {String method = 'post', data}) async {
    try {
      Response response =
          await dio.request(url, data: data, options: Options(method: 'post'));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
