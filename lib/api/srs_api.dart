import 'package:billd_live_flutter/api/request.dart';

class SRSApi {
  static getRtcV1Publish({api, sdp, streamurl, tid}) async {
    var res = await HttpRequest.post('/srs/rtcV1Publish', data: {
      'sdp': sdp,
      'streamurl': streamurl,
    });
    return res;
  }
}
