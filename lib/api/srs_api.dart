import 'package:billd_live_flutter/api/request.dart';

class SRSApi {
  static getRtcV1Publish({api, sdp, streamurl, tid}) async {
    print('kkkkkkkkk222');
    var res = await HttpRequest.post(
        'http://192.168.1.44:4300/srs/rtcV1Publish',
        data: {
          'api': api,
          'clientip': null,
          'sdp': sdp,
          'streamurl': streamurl,
          tid: tid
        });
    print(res);
    print('k322');
    return res;
  }
}
