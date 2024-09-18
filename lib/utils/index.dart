import 'dart:async';
import 'dart:math';

import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

computedBox({
  width,
  height,
  maxWidth,
  maxHeight,
  minWidth,
  minHeight,
}) {
  var ratio = height / width;
  var minWidth2 = minWidth != 0 ? minWidth : 0;
  var minHeight2 = minHeight != 0 ? minHeight : 0;
  var width2 = width;
  var height2 = height;
  billdPrint(width2, minWidth2);
  if (width2 < minWidth2) {
    width2 = minWidth2;
    height2 = minWidth2 * ratio;
  }
  billdPrint(height2, minHeight2);
  if (height2 < minHeight2) {
    width2 = minHeight2 / ratio;
    height2 = minHeight2;
  }

  if (width2 > maxWidth) {
    width2 = maxWidth;
    height2 = maxWidth * ratio;
  }
  if (height2 > maxHeight) {
    width2 = maxHeight / ratio;
    height2 = maxHeight;
  }

  return {
    'width': width2,
    'height': height2,
  };
}

Future<bool> startForegroundService() async {
  const androidConfig = FlutterBackgroundAndroidConfig(
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

handlePlayUrl(liveRoomInfo, type) {
  var url = '';
  if (liveRoomInfo == null) {
    return url;
  }
  if (type == null) {
    return url;
  }
  if (type == 'flv') {
    if (liveRoomInfo['cdn'] == liveRoomUseCDNEnum['yes']) {
      if (liveRoomInfo['type'] == liveRoomTypeEnum['tencent_css'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['tencent_css_pk']) {
        url = liveRoomInfo['cdn_flv_url'];
      } else {
        url = liveRoomInfo['flv_url'];
      }
    } else {
      url = liveRoomInfo['flv_url'];
    }
  } else if (type == 'hls') {
    if (liveRoomInfo['cdn'] == liveRoomUseCDNEnum['yes']) {
      if (liveRoomInfo['type'] == liveRoomTypeEnum['tencent_css'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['tencent_css_pk']) {
        url = liveRoomInfo['cdn_hls_url'];
      } else {
        url = liveRoomInfo['hls_url'];
      }
    } else {
      url = liveRoomInfo['hls_url'];
    }
  }
  return url;
}

handleZero(int num) {
  if (num < 10) {
    return '0$num';
  }
  return num;
}

billdGetRangeRandom(int min, int max) {
  return (Random().nextDouble() * (max - min + 1)).floor() + min;
}

billdGetRandomString(int length) {
  const str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var res = '';
  for (var i = 0; i < length; i += 1) {
    res += String.fromCharCode(
        str.codeUnitAt(billdGetRangeRandom(0, str.length - 1)));
  }
  return res;
}

billdPrint(str, [args]) {
  // ignore: avoid_print
  print('$str---$args');
}

billdNetworkImage(String url) {
  return NetworkImage(url);
}

billdRequestPermissions() async {
  var camerastatus = await Permission.camera.status;
  if (camerastatus.isDenied) {
    billdPrint('没有camera权限');
    await Permission.camera.request();
  }
  var microphonestatus = await Permission.microphone.status;
  if (microphonestatus.isDenied) {
    billdPrint('没有microphone权限');
    await Permission.microphone.request();
  }
  // var manageExternalStoragestatus =
  //     await Permission.manageExternalStorage.status;
  // if (manageExternalStoragestatus.isDenied) {
  //   billdPrint('没有manageExternalStorage权限');
  //   await Permission.manageExternalStorage.request();
  // }
  // var mediaLibrarystatus = await Permission.mediaLibrary.status;
  // if (mediaLibrarystatus.isDenied) {
  //   billdPrint('没有mediaLibrary权限');
  //   await Permission.mediaLibrary.request();
  // }
  // var ignoreBatteryOptimizationsstatus =
  //     await Permission.ignoreBatteryOptimizations.status;
  // if (ignoreBatteryOptimizationsstatus.isDenied) {
  //   billdPrint('没有ignoreBatteryOptimizations权限');
  //   await Permission.ignoreBatteryOptimizations.request();
  // }
}

Future<bool> billdModal(context,
    {String? title = '提示',
    String? cancel = '取消',
    String? confirm = '确认',
    String? message = '是否退出billd直播？'}) {
  Completer<bool> completer = Completer<bool>();
  BrnDialogManager.showConfirmDialog(context,
      title: title,
      cancel: cancel!,
      confirm: confirm!,
      message: message, onConfirm: () {
    completer.complete(true);
    Navigator.pop(context, true);
  }, onCancel: () {
    completer.complete(false);
    Navigator.pop(context, false);
  });
  // 返回Future对象
  return completer.future;
}

const loadingText = Text('加载中...');

fullLoading() {
  return Scaffold(
    body: SafeArea(
      child: Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(
              color: themeColor,
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: loadingText)
          ])),
    ),
  );
}

getAllDev() async {
  var res = await navigator.mediaDevices.enumerateDevices();
  for (var element in res) {
    billdPrint(
        'element,${element.kind},${element.label},---${element.deviceId}');
  }
  return res;
}
