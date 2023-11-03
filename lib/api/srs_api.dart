import 'package:billd_live_flutter/api/request.dart';

class SRSApi {
  static getRtcV1Publish({api, sdp, streamurl, tid}) async {
    var res = await HttpRequest.post(
        'http://192.168.1.44:4300/srs/rtcV1Publish',
        data: {
          'api': api,
          'clientip': null,
          'sdp': sdp,
          'streamurl': streamurl,
          'tid': tid
        });
    return res;
  }
}
