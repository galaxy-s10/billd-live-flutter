import 'package:billd_live_flutter/api/request.dart';

class LiveApi {
  static getLiveList() async {
    var res = await HttpRequest.get('/live/list', params: {});
    return res;
  }
}
