import 'package:billd_live_flutter/api/srs_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:bruno/bruno.dart';

class WebRTCWidget extends StatefulWidget {
  const WebRTCWidget({super.key});

  @override
  createState() => RTCState();
}

class RTCState extends State<WebRTCWidget> {
  RTCVideoRenderer? localRenderer;
  RTCPeerConnection? pc;
  bool showIcon = true;
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
      print('offer成功');
      var srsres = await SRSApi.getRtcV1Publish(
          api: '/rtc/v1/publish/',
          sdp: offer.sdp,
          streamurl:
              'rtmp://localhost/livestream/roomId___11?token=6f98374da063bc509998e51b7c1a80e2&type=2',
          tid: '4335455');
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
      // print(track);
    });
    print(stream.getTracks().length);
    print('========');
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
    handleAnswer(sdp);
  }

  @override
  Widget build(BuildContext context) {
    // handleInit();
    return Column(
      children: [
        InkWell(
          child: const Text(
            '直播',
          ),
          onTap: () {
            print('开始了');
            BrnDialogManager.showSingleButtonDialog(context,
                barrierDismissible: false,
                label: "确定",
                title: '提示',
                warning: '错误', onTap: () {
              setState(() {
                print('kkk');
                Navigator.pop(context);
              });
            });
            // handleInit();
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
    );
  }
}
