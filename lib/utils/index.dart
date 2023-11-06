import 'package:permission_handler/permission_handler.dart';

handleRequestPermissions() async {
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
    print('没有ignoreBatteryOptimizations权限');
    await Permission.ignoreBatteryOptimizations.request();
  }
}
