import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void handleStart() async {
  var pc = await createPeerConnection({
    'iceServers': [
      {
        'urls': 'turn:hsslive.cn:3478',
        'username': 'hss',
        'credential': '123456',
      },
      // {
      //   'urls': 'stun:stun.l.google.com:19302',
      // },
    ]
  });
  var offer = await pc.createOffer();
  var srsres = await SRSApi.getRtcV1Publish(
      api: '/rtc/v1/publish/',
      sdp: offer.sdp,
      streamurl:
          'rtmp://localhost/livestream/roomId___11?token=6f98374da063bc509998e51b7c1a80e2&type=2',
      tid: 'dsgsg');
  print(srsres);
  print('pc222');
}

class Rank extends StatelessWidget {
  const Rank({super.key});

  @override
  Widget build(BuildContext context) {
    handleStart();
    return Scaffold(appBar: AppBar(title: const Text('排行')));
  }
}
