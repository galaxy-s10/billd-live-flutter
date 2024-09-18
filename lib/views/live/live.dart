import 'dart:math';

import 'package:billd_live_flutter/enum.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/rtc_sdk.dart';

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
  RTCClass? _pc;
  MediaStream? _stream;
  final Controller store = get_x.Get.put(Controller());

  final List<Map<String, dynamic>> streamRadioButtons = [
    {'label': '前置', 'index': 0},
    {'label': '后置', 'index': 1},
    {'label': '屏幕', 'index': 2},
  ];

  final List<Map<String, dynamic>> typeRadioButtons = [
    {'label': 'srs直播', 'index': 0, 'val': liveRoomTypeEnum['srs']},
    {'label': 'cdn直播', 'index': 1, 'val': liveRoomTypeEnum['tencent_css']},
    {'label': 'rtc直播', 'index': 2, 'val': liveRoomTypeEnum['wertc_live']},
    // {'label': '打pk直播', 'index': 3},
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
    var offer = await _pc?.handleOffer();
    if (offer == false) {
      billdPrint('handleOffer错误', e);
      if (mounted) {
        BrnToast.show('handleOffer错误', context);
      }
    } else {
      return offer;
    }
  }

  handleAnswer(offer) async {
    var flag = false;
    if (_pc == null) return false;
    flag = await _pc!.handleAnswer(offer);
    return flag;
  }

  handleAnswerByTencentcloudCss(offer) async {
    var flag = false;
    if (_pc == null) return false;
    flag = await _pc!.handleAnswerByTencentcloudCss(offer);
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
        await startForegroundService();
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': true,
        });
      }
      if (stream != null) {
        stream.getTracks().forEach((track) async {
          await _pc?.pc?.addTrack(track, stream!);
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
      billdPrint('handleStream错误', e);
      if (mounted) {
        BrnToast.show('用户拒绝授权', context);
      }
    }
  }

  handleCloseLive() async {
    try {
      await handleClose();
      await LiveApi.getCloseLive();
    } catch (e) {
      billdPrint('handleCloseLive错误', e);
      if (mounted) {
        BrnToast.show('handleCloseLive错误', context);
      }
    }
  }

  handleClose() async {
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
    } catch (e) {
      billdPrint('handleClose错误', e);
      if (mounted) {
        BrnToast.show('handleClose错误', context);
      }
    }
  }

  handleStartLive() async {
    await handleClose();
    var res = await LiveApi.getIsLive();
    if (res['data'].length == 0) {
      await LiveApi.updateMyLiveRoomInfo(
          {"type": typeRadioButtons[typeIndex]['val']});
      _pc = RTCClass();
      await _pc?.init();
      await handleStream();
      var offer = await handleOffer();
      var flag = false;
      if (typeRadioButtons[typeIndex]['index'] == 0) {
        flag = await handleAnswer(offer);
      } else if (typeRadioButtons[typeIndex]['index'] == 1) {
        flag = await handleAnswerByTencentcloudCss(offer);
      } else if (typeRadioButtons[typeIndex]['index'] == 2) {}

      if (flag) {
        if (mounted) {
          BrnToast.show('开播成功', context, duration: const Duration(seconds: 1));
        }
        setState(() {
          status = LiveStatus.living;
        });
      } else {
        if (mounted) {
          BrnToast.show('handleStartLive错误', context);
        }
      }
    } else {
      if (mounted) {
        BrnDialogManager.showConfirmDialog(context,
            title: "提示",
            cancel: '取消',
            confirm: '确定',
            message: "当前正在直播，是否先断开直播？", onConfirm: () async {
          await handleCloseLive();
          setState(() {
            status = LiveStatus.nolive;
          });
          if (mounted) {
            BrnToast.show('断开直播成功', context,
                duration: const Duration(seconds: 1));
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
                const Text("画面："),
                ...streamRadioButtons.map((item) {
                  return BrnRadioButton(
                    radioIndex: item['index'],
                    isSelected: streamIndex == item['index'],
                    child: Text(item['label']),
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
              const Text("类型："),
              ...typeRadioButtons.map((radioButton) {
                return BrnRadioButton(
                  radioIndex: radioButton['index'],
                  isSelected: typeIndex == radioButton['index'],
                  child: Text(radioButton['label']),
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
                            BrnToast.show('关闭直播成功', context,
                                duration: const Duration(seconds: 1));
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
