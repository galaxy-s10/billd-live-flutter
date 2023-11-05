import 'dart:async';

import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:bruno/bruno.dart';
import 'package:get/get.dart' as get_x;

class WebRTCWidget extends StatefulWidget {
  const WebRTCWidget({super.key});

  @override
  createState() => RTCState();
}

class RTCState extends State<WebRTCWidget> {
  RTCVideoRenderer? _localRenderer;
  RTCPeerConnection? _pc;
  bool showIcon = true;
  MediaStream? _stream;
  final Controller store = get_x.Get.put(Controller());

  var mode = [
    {'label': '前置', 'value': 'front'},
    {'label': '后置', 'value': 'back'},
    {'label': '屏幕', 'value': 'screen'},
  ];

  var modeIndex = 0;

  @override
  initState() {
    super.initState();
  }

  handleOffer() async {
    // _pc!.addTransceiver(
    //   kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
    //   init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    // );
    // _pc!.addTransceiver(
    //   kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
    //   init: RTCRtpTransceiverInit(direction: TransceiverDirection.SendRecv),
    // );
    try {
      var offer = await _pc!.createOffer({});
      await _pc!.setLocalDescription(offer);
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
      await _pc!.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      print('设置远程描述成功');
    } catch (e) {
      print('设置远程描述失败');
      print(e);
    }
  }

  handleStream() async {
    try {
      var stream;
      if (mode[modeIndex]['value'] == 'front') {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            // 'mandatory': {
            //   'maxWidth': '1280', // 设置最大宽度
            //   'maxHeight': '720', // 设置最大高度
            // },
            'facingMode': 'user', // 指定前置摄像头
          },
          'audio': true,
          'facingMode': 'user', // 指定前置摄像头
        });
      } else if (mode[modeIndex]['value'] == 'back') {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            // 'mandatory': {
            //   'maxWidth': '1280', // 设置最大宽度
            //   'maxHeight': '720', // 设置最大高度
            // },
            'facingMode': 'environment', // 指定后置摄像头
          },
          'audio': true,
        });
      } else if (mode[modeIndex]['value'] == 'screen') {
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': true,
        });
      }
      if (stream != null) {
        stream.getTracks().forEach((track) async {
          await _pc?.addTrack(track, stream);
        });
        setState(() {
          _stream = stream;
          _localRenderer!.srcObject = stream;
        });
      }
    } catch (e) {
      print(e);
      BrnToast.show('拒绝授权', context);
    }
  }

  Future<bool> startForegroundService() async {
    final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
  }

  handleCloseLive() async {
    if (_pc != null) {
      _pc!.close();
      _pc = null;
    }
    if (_stream != null) {
      _stream!.dispose();
      _stream = null;
    }
    if (_localRenderer != null) {
      _localRenderer!.srcObject = null;
      _localRenderer!.dispose();
      _localRenderer = null;
    }
    await LiveApi.getCloseLive();
  }

  handleInit() async {
    // WidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    await startForegroundService();
    _localRenderer = RTCVideoRenderer();
    await _localRenderer!.initialize();
    if (_pc != null) {
      await _pc!.close();
    }
    var res = await LiveApi.getIsLive();
    if (res['data'].length == 0) {
      _pc = await createPeerConnection({
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
        // 'sdpSemantics': "unified-plan" //加不加好像都可以
      });
      await handleStream();
      var sdp = await handleOffer();
      if (sdp != null) {
        handleAnswer(sdp);
      } else {
        BrnToast.show('offer错误', context);
      }
    } else {
      BrnDialogManager.showConfirmDialog(context,
          title: "提示",
          cancel: '取消',
          confirm: '确定',
          message: "当前正在直播，是否先断开直播？", onConfirm: () async {
        await LiveApi.getCloseLive();
        BrnToast.show('断开直播成功', context);
        Navigator.pop(context, true);
      }, onCancel: () {
        Navigator.pop(context, false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double height =
        size.height - kBottomNavigationBarHeight - store.safeHeight.value;
    Future<bool> BrnDialog() {
      Completer<bool> completer = Completer<bool>();

      BrnDialogManager.showConfirmDialog(context,
          title: "提示",
          cancel: '取消',
          confirm: '确定',
          message: "是否退出直播？", onConfirm: () {
        handleCloseLive();
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
            Container(
              height: height - 100,
              width: size.width,
              child: _localRenderer != null
                  ? RTCVideoView(
                      _localRenderer!,
                      // mirror: true,
                    )
                  : null,
            ),
            BrnBigGhostButton(
              title: '切换前/后摄像头/屏幕(当前：${mode[modeIndex]['label']})',
              onTap: () {
                if (modeIndex < mode.length - 1) {
                  setState(() {
                    modeIndex += 1;
                  });
                } else {
                  setState(() {
                    modeIndex = 0;
                  });
                }
              },
            ),
            BrnBigGhostButton(
              title: '开始直播',
              onTap: () {
                handleInit();
              },
            ),
            BrnBigGhostButton(
              bgColor: const Color.fromRGBO(244, 67, 54, 0.2),
              titleColor: const Color.fromRGBO(244, 67, 54, 1),
              title: '关闭直播',
              onTap: () {
                BrnDialogManager.showConfirmDialog(context,
                    barrierDismissible: false,
                    title: '提示',
                    message: '确定关闭直播？',
                    cancel: '取消',
                    confirm: '确定',
                    onCancel: () => {Navigator.pop(context)},
                    onConfirm: () {
                      setState(() {
                        BrnToast.show('关闭直播成功', context);
                        handleCloseLive();
                        Navigator.pop(context);
                      });
                    });
              },
            ),
          ],
        ),
        onWillPop: () async {
          return await BrnDialog();
        });
  }
}
