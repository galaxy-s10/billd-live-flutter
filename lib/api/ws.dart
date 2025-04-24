import 'package:billd_live_flutter/utils/request.dart';

class WsApi {
  static getWsInfo() async {
    var res = await HttpRequest.get('/ws/get_ws_info');
    return res;
  }
}
