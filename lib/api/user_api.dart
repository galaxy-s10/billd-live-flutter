import 'package:billd_live_flutter/utils/request.dart';

class UserApi {
  static idLogin({required int id, required String password}) async {
    var res = await HttpRequest.post('/user/login',
        data: {'id': id, 'password': password});
    return res;
  }

  static usernameLogin(
      {required String username, required String password}) async {
    var res = await HttpRequest.post('/user/username_login',
        data: {'username': username, 'password': password});
    return res;
  }

  static getUserInfo() async {
    var res = await HttpRequest.get('/user/get_user_info', params: {});
    return res;
  }
}
