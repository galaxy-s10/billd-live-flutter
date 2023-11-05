import 'package:billd_live_flutter/models/webrtc.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

requestPermissions() async {
  var camerastatus = await Permission.camera.status;
  if (camerastatus.isDenied) {
    print('没有camera权限');
    await Permission.camera.request();
  }
  var microphonestatus = await Permission.microphone.status;
  if (microphonestatus.isDenied) {
    print('没有microphone权限');
    await Permission.microphone.request();
  }
  var ignoreBatteryOptimizationsstatus =
      await Permission.ignoreBatteryOptimizations.status;
  if (ignoreBatteryOptimizationsstatus.isDenied) {
    print('没有ignoreBatteryOptimizationsstatus权限');
    await Permission.ignoreBatteryOptimizations.request();
  }
}

class Live extends StatelessWidget {
  const Live({super.key});

  @override
  Widget build(BuildContext context) {
    requestPermissions();
    return const SafeArea(
        child: Scaffold(
      body: WebRTCWidget(),
    ));
  }
}
