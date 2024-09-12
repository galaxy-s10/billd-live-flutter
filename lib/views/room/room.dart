import 'dart:async';

import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/ws_sdk.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as get_x;
import 'package:video_player/video_player.dart';
import 'package:billd_live_flutter/utils/index.dart';

class Room extends StatefulWidget {
  final String hlsurl;
  final String flvurl;
  final String avatar;
  final String username;
  final int liveRoomId;
  final dynamic liveRoomInfo;

  const Room({
    required this.flvurl,
    required this.hlsurl,
    required this.avatar,
    required this.username,
    required this.liveRoomId,
    required this.liveRoomInfo,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => RankState();
}

class RankState extends State<Room> {
  var loading = false;
  final Controller store = get_x.Get.put(Controller());
  MediaStream? stream;
  RTCVideoRenderer? remoteRenderer;
  var show;

  RTCPeerConnection? _pc;
  String flvurl = '';
  String hlsurl = '';
  String avatar = '';
  String username = '';
  int liveRoomId = -1;
  var liveRoomInfo;
  var timer;
  var receiver;
  var videoRatio = normalVideoRatio;

  WsClass? ws;
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    // ws.init();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      billdPrint(ws?.send, '3634732134');
      // ws?.send(wsMsgTypeEnum['message']!, billdGetRandomString(8), {});
    });
    liveRoomId = widget.liveRoomId;
    liveRoomInfo = widget.liveRoomInfo;
    hlsurl = widget.hlsurl;
    avatar = widget.avatar;
    username = widget.username;
    handleStream();
    // playVideo(widget.hlsurl);
  }

  @override
  void dispose() {
    timer.cancel();
    stopVideo();
    if (ws != null) {
      ws?.socket.off(wsMsgTypeEnum['connect']!);
      ws?.socket.off(wsMsgTypeEnum['joined']!);
      ws?.socket.off(wsMsgTypeEnum['nativeWebRtcOffer']!);
      ws?.socket.off(wsMsgTypeEnum['nativeWebRtcCandidate']!);
      ws?.close();
    }
    super.dispose();
  }

  getAllDev() async {
    var res = await navigator.mediaDevices.enumerateDevices();
    for (var element in res) {
      billdPrint(
          'element22,${element.kind},${element.label},---${element.deviceId}');
    }
    return res;
  }

  handleStream() async {
    startForegroundService();
    try {
      var ss = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': true,
      });
      billdPrint('sssss', ss);
      ss.getTracks().forEach((track) {
        _pc?.addTrack(track, ss);
      });
      setState(() {
        stream = ss;
      });
      handleInitWs();
    } catch (e) {
      billdPrint('报错了');
      billdPrint(e);
      if (context.mounted) {
        BrnToast.show('拒绝授权', context);
      }
    }
  }

  handleInitWs() {
    billdPrint('handleInitWshandleInitWs');
    setState(() {
      ws = WsClass();
    });
    ws?.socket.on('connect', (data) {
      billdPrint('connectconnectconnect');
      sendJoin();
    });
    ws?.socket.on(wsMsgTypeEnum['joined']!, (data) {
      if (liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_one'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_two'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['pk']) {
        sendBatchSendOffer();
      }
    });
    ws?.socket.on(wsMsgTypeEnum['nativeWebRtcCandidate']!, (data) {
      billdPrint('nativeWebRtcCandidate', data);
      if (data['receiver'] == ws?.socket.id) {
        billdPrint('是发给我的nativeWebRtcCandidate', data['candidate']);
        RTCIceCandidate iceCandidate =
            RTCIceCandidate(data['candidate']['candidate'], 'label', 0);
        _pc?.addCandidate(iceCandidate);
      }
    });
    ws?.socket.on(wsMsgTypeEnum['nativeWebRtcOffer']!, (data) async {
      billdPrint('nativeWebRtcOffer', data);
      if (data['receiver'] == ws?.socket.id) {
        billdPrint('是发给我的nativeWebRtcOffer');
        _pc = await createPeerConnection({});
        billdPrint('pcc', _pc);
        setState(() {
          receiver = data['sender'];
        });

        if (_pc != null) {
          // 设置 onTrack 事件
          _pc!.onTrack = (RTCTrackEvent event) async {
            billdPrint('tttt', event);
            if (event.track.kind == 'video') {
              var rtcvideo = RTCVideoRenderer();
              await rtcvideo.initialize();
              // 监听视频轨道的流
              for (var stream in event.streams) {
                rtcvideo.srcObject = stream;
              }
              setState(() {
                remoteRenderer = rtcvideo;
                show = true;
              });
            }
          };
          _pc!.onIceCandidate = (RTCIceCandidate event) {
            billdPrint('onIceCandidate', event);
            billdPrint('onIceCandidate', event.candidate);
            sendNativeWebRtcCandidate({
              'candidate': event.candidate,
              'sdpMid': event.sdpMid,
              'sdpMLineIndex': event.sdpMLineIndex,
            }, receiver);
          };
        }
        billdPrint('streamstream', data['sdp']);
        if (stream != null) {
          stream?.getTracks().forEach((track) async {
            billdPrint('==addTrack');
            await _pc?.addTrack(track, stream!);
          });
          // 创建 RTCSessionDescription
          RTCSessionDescription offer =
              RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']);
          // await _pc?.setLocalDescription(offer);
          await _pc?.setRemoteDescription(offer);
          var answerSdp = await _pc?.createAnswer();
          if (answerSdp != null) {
            billdPrint('==setLocalDescription');
            await _pc?.setLocalDescription(answerSdp);
            sendNativeWebRtcAnswer(answerSdp, data['sender']);
          }
        }
      }
    });
    if (liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_one'] ||
        liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_two'] ||
        liveRoomInfo['type'] == liveRoomTypeEnum['pk']) {
      return;
    }
  }

  sendNativeWebRtcCandidate(candidate, receiver) {
    billdPrint('sendNativeWebRtcCandidate', candidate);
    ws?.send(wsMsgTypeEnum['nativeWebRtcCandidate']!, billdGetRandomString(8), {
      'candidate': candidate,
      'live_room_id': liveRoomId,
      'sender': ws?.socket.id,
      'receiver': receiver,
    });
  }

  sendJoin() {
    ws?.send(wsMsgTypeEnum['join']!, billdGetRandomString(8), {
      'isBilibili': false,
      'isRemoteDesk': false,
      'live_room_id': liveRoomId,
      'user_info': null,
    });
  }

  sendNativeWebRtcAnswer(answerSdp, receiver) {
    billdPrint(
      'sendNativeWebRtcAnswer',
      receiver,
    );
    ws?.send(wsMsgTypeEnum['nativeWebRtcAnswer']!, billdGetRandomString(8), {
      'live_room_id': liveRoomId,
      'sender': ws?.socket.id,
      'receiver': receiver,
      'sdp': {'type': answerSdp.type, 'sdp': answerSdp.sdp},
    });
  }

  sendBatchSendOffer() {
    billdPrint('batchSendOffer', liveRoomId);
    ws?.send(wsMsgTypeEnum['batchSendOffer']!, billdGetRandomString(8), {
      'roomId': liveRoomId,
    });
  }

  playVideo(String url) async {
    try {
      setState(() {
        loading = true;
      });
      await stopVideo();
      String newurl = url.replaceAll('localhost', localIp);
      var res = VideoPlayerController.networkUrl(Uri.parse(newurl),
          videoPlayerOptions: VideoPlayerOptions());
      _controller = res;
      setState(() {});
      await res.initialize();
      await res.play();
      videoRatio = res.value.aspectRatio;
      setState(() {
        loading = false;
      });
    } catch (e) {
      billdPrint(e);
      if (context.mounted) {
        BrnToast.show('播放错误', context);
      }
    }
  }

  stopVideo() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var id = ws?.socket.id;
    id ??= '';
    return Scaffold(
        body: SafeArea(
            child: Container(
      color: const Color.fromRGBO(12, 22, 34, 1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              children: [
                avatar == ''
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      )
                    : SizedBox(
                        width: 40,
                        height: 40,
                        child: CircleAvatar(
                          backgroundImage: billdNetworkImage(avatar),
                        )),
                Container(
                    width: 200,
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      username,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ))
              ],
            ),
          ),
          loading
              ? const Center(
                  child: Text(
                    '加载中...',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 20,
                    ),
                  ),
                )
              : _controller != null
                  ? AspectRatio(
                      aspectRatio: videoRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(
                      color: Colors.white,
                    ),
          GestureDetector(
            child: Text(
              liveRoomTypeEnumMap[liveRoomInfo['type']]!,
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          GestureDetector(
            child: Text(
              id,
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {},
          ),
          SizedBox(
              height: 200,
              width: 200,
              child: remoteRenderer != null
                  ? RTCVideoView(
                      remoteRenderer!,
                      // mirror: true,
                    )
                  : Container()),
        ],
      ),
    )));
  }
}
