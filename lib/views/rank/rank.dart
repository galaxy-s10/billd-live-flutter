import 'package:billd_live_flutter/models/webrtc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:core';

requestPermissions() async {
  var camerastatus = await Permission.camera.status;
  if (camerastatus.isDenied) {
    print('没有camera权限');
    var res1 = await Permission.camera.request();
  }
  var microphonestatus = await Permission.microphone.status;
  if (microphonestatus.isDenied) {
    print('没有microphone权限');
    Permission.microphone.request();
  }
}

class Rank extends StatelessWidget {
  const Rank({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('排行')),
        body: Column(children: [
          InkWell(
            child: const Text(
              'dd322',
            ),
            onTap: () {
              print('333');
            },
          ),
          WebRTCWidget(),
          // const Text('ddd'),
        ]));
  }
}
