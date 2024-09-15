import 'dart:math';
import 'package:billd_live_flutter/api/tencentcloud_css_api.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:billd_live_flutter/utils/index.dart';

import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:billd_live_flutter/stores/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:bruno/bruno.dart';
import 'package:get/get.dart' as get_x;

enum LiveStatus { nolive, living }

class WebRTCWidget extends StatefulWidget {
  const WebRTCWidget({super.key});

  @override
  createState() => RTCState();
}

class RTCState extends State<WebRTCWidget> {
  RTCVideoRenderer? _localRenderer;
  RTCPeerConnection? _pc;
  MediaStream? _stream;
  final Controller store = get_x.Get.put(Controller());

  final List<Map<String, dynamic>> streamRadioButtons = [
    {'label': '前置', 'index': 0},
    {'label': '后置', 'index': 1},
    {'label': '屏幕', 'index': 2},
  ];

  final List<Map<String, dynamic>> typeRadioButtons = [
    {'label': 'srs直播', 'index': 0},
    {'label': 'cdn直播', 'index': 1},
    {'label': '打pk直播', 'index': 2},
  ];

  var streamIndex = 0;
  var typeIndex = 0;
  var status = LiveStatus.nolive;

  @override
  initState() {
    super.initState();
    getAllDev();
  }

  handleOffer() async {
    try {
      var offer = await _pc!.createOffer({});
      billdPrint('创建offer成功', offer);
      await _pc!.setLocalDescription(offer);
      billdPrint('设置本地描述成功');
      return offer;
    } catch (e) {
      billdPrint('handleOffer失败');
      billdPrint(e);
      if (context.mounted) {
        BrnToast.show('handleOffer失败', context);
      }
    }
  }

  handleAnswer(offer) async {
    var flag = false;
    try {
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      String streamurl =
          '${liveRoomInfo['rtmp_url']}?pushkey=${liveRoomInfo['key']}&pushtype=${liveRoomTypeEnum['srs']}';
      billdPrint('dsfdsg', offer.sdp);
      var srsres = await SRSApi.getRtcV1Publish(
          api: '/rtc/v1/publish/',
          sdp: offer.sdp,
          streamurl: streamurl,
          tid: Random().nextDouble().toString().substring(2));
      if (srsres['data']['code'] == 400) {
        flag = false;
        billdPrint('获取remotesdp错误', srsres['data']);
        if (context.mounted) {
          BrnToast.show('获取remotesdp错误', context);
        }
      } else {
        await _pc!.setRemoteDescription(
            RTCSessionDescription(srsres['data']['sdp'], 'answer'));
        billdPrint('设置远程描述成功');
        flag = true;
      }
    } catch (e) {
      billdPrint('handleAnswer失败');
      billdPrint(e);
      flag = false;
      if (context.mounted) {
        BrnToast.show('handleAnswer失败', context);
      }
    }
    return flag;
  }

  handleAnswerByCss(offer) async {
    var flag = false;
    try {
      var liveRoomInfo = store.userInfo['live_rooms'][0];
      var pushurlRes = await TencentcloudCssApi.push(liveRoomInfo['id']);
      billdPrint('pushurlRes', pushurlRes);
      if (pushurlRes['code'] == 200) {
        String streamurl = pushurlRes['data']['push_webrtc_url'];
        var cssres = await TencentcloudCssApi.pushstream(
          sdp: offer.sdp,
          streamurl: streamurl,
          sessionid: billdGetRandomString(21),
        );
        billdPrint('cssres', cssres);
        if (cssres['errcode'] != 0) {
          flag = false;
          billdPrint('获取remotesdp错误', cssres['data']);
          if (context.mounted) {
            BrnToast.show('获取remotesdp错误', context);
          }
        } else {
          billdPrint('ddsds', cssres['remotesdp']['sdp']);
          await _pc!.setRemoteDescription(
              RTCSessionDescription(cssres['remotesdp']['sdp'], 'answer'));
          billdPrint('设置远程描述成功');
          flag = true;
        }
      }
    } catch (e) {
      billdPrint('handleAnswerByCss失败');
      billdPrint(e);
      flag = false;
      if (context.mounted) {
        BrnToast.show('handleAnswerByCss失败', context);
      }
    }
    return flag;
  }

  handleStream() async {
    MediaStream? stream;
    try {
      if (streamRadioButtons[streamIndex]['index'] == 0) {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            'mandatory': {
              'facingMode': 'user', // 指定前置摄像头
            },
          },
          'audio': true,
        });
      } else if (streamRadioButtons[streamIndex]['index'] == 1) {
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {
            'facingMode': 'environment', // 指定后置摄像头
          },
          'audio': true,
        });
      } else if (streamRadioButtons[streamIndex]['index'] == 2) {
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': true,
        });
      }
      if (stream != null) {
        stream.getTracks().forEach((track) async {
          await _pc?.addTrack(track, stream!);
        });
        var localRenderer = RTCVideoRenderer();
        await localRenderer.initialize();
        localRenderer.srcObject = stream;
        setState(() {
          _stream = stream;
          _localRenderer = localRenderer;
        });
      }
    } catch (e) {
      billdPrint('报错了');
      billdPrint(e);
      if (context.mounted) {
        BrnToast.show('拒绝授权', context);
      }
    }
  }

  handleCloseLive() async {
    try {
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
    } catch (e) {
      billdPrint('handleCloseLive失败');
      if (context.mounted) {
        BrnToast.show('handleCloseLive失败', context);
      }
    }
  }

  handleStartLive() async {
    await startForegroundService();
    if (_pc != null) {
      await _pc!.close();
    }
    var res = await LiveApi.getIsLive();
    if (res['data'].length == 0) {
      _pc = await createPeerConnection({
        // 'iceServers': [
        //   {
        //     'urls': 'turn:hk.hsslive.cn',
        //     'username': 'hss',
        //     'credential': '123456',
        //   },
        // ]
      });
      await handleStream();
      var offer = await handleOffer();
      var flag = false;
      if (typeRadioButtons[streamIndex]['index'] == 0) {
        flag = await handleAnswer(offer);
      } else if (typeRadioButtons[streamIndex]['index'] == 1) {
        flag = await handleAnswerByCss(offer);
      } else if (typeRadioButtons[streamIndex]['index'] == 2) {}

      if (flag) {
        setState(() {
          status = LiveStatus.living;
        });
      }
    } else {
      if (context.mounted) {
        BrnDialogManager.showConfirmDialog(context,
            title: "提示",
            cancel: '取消',
            confirm: '确定',
            message: "当前正在直播，是否先断开直播？", onConfirm: () async {
          await handleCloseLive();
          setState(() {
            status = LiveStatus.nolive;
          });
          if (context.mounted) {
            BrnToast.show('断开直播成功', context);
            Navigator.pop(context, true);
          }
        }, onCancel: () {
          Navigator.pop(context, false);
        });
      }
    }
  }

  @override
  void dispose() async {
    handleCloseLive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double height =
        size.height - kBottomNavigationBarHeight - store.safeHeight.value;

    return Column(
      children: [
        SizedBox(
          height: height - 55,
          width: size.width,
          child: _localRenderer != null
              ? RTCVideoView(
                  _localRenderer!,
                  // mirror: true,
                )
              : null,
        ),
        SizedBox(
            height: 30,
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                const Text("直播画面："),
                ...streamRadioButtons.map((item) {
                  return BrnRadioButton(
                    radioIndex: item['index'],
                    isSelected: streamIndex == item['index'],
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(item['label']),
                    ),
                    onValueChangedAtIndex: (index, value) {
                      setState(() {
                        streamIndex = index;
                      });
                    },
                  );
                }).toList()
              ],
            )),
        SizedBox(
          height: 30,
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Text("直播类型："),
              ...typeRadioButtons.map((radioButton) {
                return BrnRadioButton(
                  radioIndex: radioButton['index'],
                  isSelected: typeIndex == radioButton['index'],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(radioButton['label']),
                  ),
                  onValueChangedAtIndex: (index, value) {
                    setState(() {
                      typeIndex = index;
                    });
                  },
                );
              }).toList()
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: status == LiveStatus.nolive
              ? BrnBigGhostButton(
                  title: '开始直播',
                  onTap: () async {
                    BrnDialogManager.showConfirmDialog(context,
                        title: '提示',
                        cancel: '取消',
                        confirm: '确认',
                        message: '是否开播', onConfirm: () async {
                      Navigator.pop(context, true);
                      await LiveApi.getCloseLive();
                      handleStartLive();
                    }, onCancel: () {
                      Navigator.pop(context, false);
                    });
                  },
                )
              : BrnBigGhostButton(
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
                        onConfirm: () async {
                          await handleCloseLive();
                          setState(() {
                            status = LiveStatus.nolive;
                            BrnToast.show('关闭直播成功', context);
                            Navigator.pop(context);
                          });
                        });
                  },
                ),
        )
      ],
    );
  }
}

class Live extends StatelessWidget {
  const Live({super.key});

  @override
  Widget build(BuildContext context) {
    billdRequestPermissions();
    return const SafeArea(
        child: Scaffold(
      body: WebRTCWidget(),
    ));
  }
}
