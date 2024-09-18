import 'package:billd_live_flutter/api/request.dart';

class LiveApi {
  static getLiveList() async {
    var res = await HttpRequest.get('/live/list', params: {});
    return res;
  }

  static getIsLive() async {
    var res = await HttpRequest.get('/live/is_live', params: {});
    return res;
  }

  static getCloseLive() async {
    var res = await HttpRequest.post('/live/close_live', data: {});
    return res;
  }

  static updateMyLiveRoomInfo(data) async {
    var res =
        await HttpRequest.post('/live/update_my_live_room_info', data: data);
    return res;
  }

  static getliveRoomOnlineUser(params) async {
    var res =
        await HttpRequest.get('/live/live_room_online_user', params: params);
    return res;
  }
}
