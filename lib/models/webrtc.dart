import 'dart:async';

import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:billd_live_flutter/main.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:bruno/bruno.dart';
import 'package:get/get.dart' as get_x;

class WebRTCWidget extends StatefulWidget {
  const WebRTCWidget({super.key});

  @override
  createState() => RTCState();
}

class RTCState extends State<WebRTCWidget> {
  RTCVideoRenderer? localRenderer;
  RTCPeerConnection? pc;
  bool showIcon = true;
  final Controller store = get_x.Get.put(Controller());

  handleOffer() async {
    pc!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    );
    // pc!.addTransceiver(
    //   kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
    //   init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    // );
    try {
      var offer = await pc!.createOffer({});
      await pc!.setLocalDescription(offer);
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      print('offer成功');
      String newurl = liveRoomInfo['rtmp_url'];
      String streamurl = '${newurl}?token=${liveRoomInfo['key']}&type=2';
      print(streamurl);
      print('推流地址');
      var srsres = await SRSApi.getRtcV1Publish(
          api: '/rtc/v1/publish/',
          sdp: offer.sdp,
          streamurl: streamurl,
          tid: '4335455');
      if (srsres['data']['code'] == 400) {
        BrnToast.show('推流错误', context);
        return;
      }
      return srsres['data']['sdp'];
    } catch (e) {
      print(e);
      print('offer失败');
    }
  }

  handleAnswer(sdp) async {
    try {
      await pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      print('设置远程描述成功');
    } catch (e) {
      print('设置远程描述失败');
      print(e);
    }
  }

  handleStream() async {
    var stream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });
    stream.getTracks().forEach((track) async {
      await pc?.addTrack(track, stream);
    });
    setState(() {
      localRenderer!.srcObject = stream;
    });
  }

  handleInit() async {
    localRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    if (pc != null) {
      await pc!.close();
    }
    pc = await createPeerConnection({
      // 'iceServers': [
      //   {
      //     'urls': 'turn:hsslive.cn:3478',
      //     'username': 'hss',
      //     'credential': '123456',
      //   },
      //   // {
      //   //   'urls': 'stun:stun.l.google.com:19302',
      //   // },
      // ]
      'sdpSemantics': "unified-plan"
    });
    await handleStream();
    var sdp = await handleOffer();
    if (sdp != null) {
      handleAnswer(sdp);
    } else {
      BrnToast.show('offer错误', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // handleInit();

    Future<bool> BrnDialog() {
      Completer<bool> completer = Completer<bool>();

      BrnDialogManager.showConfirmDialog(context,
          title: "提示",
          cancel: '取消',
          confirm: '确定',
          message: "是否退出直播？", onConfirm: () {
        completer.complete(true);
        Navigator.pop(context, true);
      }, onCancel: () {
        completer.complete(false);
        Navigator.pop(context, false);
      });

      // 返回Future对象
      return completer.future;
    }

    return WillPopScope(
        child: Column(
          children: [
            BrnBigGhostButton(
              title: '开始直播',
              onTap: () {
                handleInit();
                // BrnDialogManager.showSingleButtonDialog(context,
                //     barrierDismissible: false,
                //     label: "确定",
                //     title: '提示',
                //     warning: '错误', onTap: () {
                //   setState(() {
                //     Navigator.pop(context);
                //   });
                // });
              },
            ),
            Container(
              height: 300,
              width: 300,
              color: Colors.red,
              child: localRenderer != null
                  ? RTCVideoView(
                      localRenderer!,
                      // mirror: true,
                    )
                  : null,
            )
          ],
        ),
        onWillPop: () async {
          print('onWillPoponWillPop');
          // BrnDialogManager.showConfirmDialog(context,
          //     title: "标题内容",
          //     cancel: '取消',
          //     confirm: '确定',
          //     message: "辅助内容信息辅助内容信息辅助内容信息辅助内容信息辅助内容信息。");
          return await BrnDialog();
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('确认退出'),
              content: Text('确定要退出应用吗？'),
              actions: [
                TextButton(
                  child: Text('取消'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );
        });
  }
}
