import 'package:billd_live_flutter/api/request.dart';

class AreaApi {
  static getAreaAreaLiveRoomList() async {
    var res = await HttpRequest.get('/area/area_live_room_list', params: {});
    return res;
  }

  static getAreaLiveRoomList(id, nowPage, pageSize) async {
    var res = await HttpRequest.get('/area/live_room_list',
        params: {'id': id, 'nowPage': nowPage, 'pageSize': pageSize});
    return res;
  }
}
