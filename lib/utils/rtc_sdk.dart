import 'dart:async';
import 'dart:math';

import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:billd_live_flutter/api/tencentcloud_css_api.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:get/get.dart' as get_x;

class RTCClass {
  RTCPeerConnection? pc;
  final Controller store = get_x.Get.put(Controller());
  var outboundFps = 0;
  var inboundFps = 0;
  RTCClass();

  init() async {
    pc = await createPeerConnection({});
  }

  handleOffer() async {
    try {
      if (pc == null) return false;
      var offer = await pc!.createOffer({});
      billdPrint('创建offer成功', offer);
      await pc!.setLocalDescription(offer);
      billdPrint('设置本地描述成功');
      return offer;
    } catch (e) {
      billdPrint('handleOffer错误', e);
      return false;
    }
  }

  handleAnswer(offer) async {
    var flag = false;
    try {
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      String streamurl =
          '${liveRoomInfo['rtmp_url']}?pushkey=${liveRoomInfo['key']}&pushtype=${liveRoomTypeEnum['srs']}';
      var res = await SRSApi.getRtcV1Publish(
          api: '/rtc/v1/publish/',
          sdp: offer.sdp,
          streamurl: streamurl,
          tid: Random().nextDouble().toString().substring(2));
      if (res['data']['code'] == 400) {
        flag = false;
        billdPrint('获取remotesdp错误', res['data']);
      } else {
        await pc!.setRemoteDescription(
            RTCSessionDescription(res['data']['sdp'], 'answer'));
        billdPrint('设置远程描述成功');
        flag = true;
      }
    } catch (e) {
      billdPrint('handleAnswer错误', e);
      flag = false;
    }
    return flag;
  }

  handleAnswerByTencentcloudCss(offer) async {
    var flag = false;
    try {
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      var pushurlRes = await TencentcloudCssApi.push(liveRoomInfo['id']);
      if (pushurlRes['code'] == 200) {
        String streamurl = pushurlRes['data']['push_webrtc_url'];
        var pushtype = liveRoomTypeEnum['tencent_css'];
        streamurl =
            streamurl.replaceAll(RegExp(r'pushtype=\d+'), 'pushtype=$pushtype');
        var res = await TencentcloudCssApi.pushstream(
          sdp: offer.sdp,
          streamurl: streamurl,
          sessionid: billdGetRandomString(21),
        );
        if (res['errcode'] != 0) {
          flag = false;
          billdPrint('获取remotesdp错误', res['data']);
        } else {
          await pc!.setRemoteDescription(
              RTCSessionDescription(res['remotesdp']['sdp'], 'answer'));
          billdPrint('设置远程描述成功');
          flag = true;
        }
      }
    } catch (e) {
      billdPrint('handleAnswerByTencentcloudCss错误', e);
      flag = false;
    }
    return flag;
  }

  close() {
    billdPrint('===close===');
  }
}
