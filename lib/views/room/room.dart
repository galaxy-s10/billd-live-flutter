import 'dart:async';

import 'package:billd_live_flutter/api/live_api.dart';
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
  final dynamic liveRoomInfo;

  const Room({
    required this.liveRoomInfo,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => RankState();
}

class RankState extends State<Room> with TickerProviderStateMixin {
  final Controller store = get_x.Get.put(Controller());
  MediaStream? _stream;
  RTCVideoRenderer? _remoteRenderer;
  RTCPeerConnection? _pc;
  WsClass? ws;
  VideoPlayerController? _controller;
  String flvurl = '';
  String hlsurl = '';
  String avatar = '';
  String username = '';
  int liveRoomId = -1;
  var liveRoomInfo;
  var timer;
  var receiver;
  var videoRatio = normalVideoRatio;
  var videoWidth = 200.0;
  var videoHeight = 300.0;
  var videoBox = {'width': 0.0, 'height': 0.0};
  var loading = false;
  var showRtc = false;
  var tabIndex = 0;

  var onlineUserList = [];
  var onlineUserTimer;

  final List<BadgeTab> tabs = [
    BadgeTab(text: "聊天"),
    BadgeTab(text: "直播间信息"),
    BadgeTab(text: "在线用户"),
  ];
  TabController? tabController;

  @override
  initState() {
    super.initState();
    videoWidth = store.screenWidth.value;
    tabController = TabController(length: tabs.length, vsync: this);
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      billdPrint('3634732134');
    });
    liveRoomInfo = widget.liveRoomInfo;
    liveRoomId = widget.liveRoomInfo['id'];
    hlsurl = handlePlayUrl(widget.liveRoomInfo, 'hls');
    flvurl = handlePlayUrl(widget.liveRoomInfo, 'flv');
    avatar = widget.liveRoomInfo?['users']?[0]?['avatar'] ?? '';
    username = widget.liveRoomInfo?['users']?[0]?['username'] ?? '';
    loopGetliveRoomOnlineUser();
    if ([
      liveRoomTypeEnum['system'],
      liveRoomTypeEnum['srs'],
      liveRoomTypeEnum['obs'],
      liveRoomTypeEnum['msr'],
      liveRoomTypeEnum['pk'],
      liveRoomTypeEnum['tencent_css'],
      liveRoomTypeEnum['tencent_css_pk'],
    ].contains(liveRoomInfo['type'])) {
      playVideo(hlsurl);
    } else {
      showRtc = true;
      handleStream();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    onlineUserTimer?.cancel();
    stopVideo();
    if (ws != null) {
      ws?.socket.off(wsMsgTypeEnum['connect']!);
      ws?.socket.off(wsMsgTypeEnum['joined']!);
      ws?.socket.off(wsMsgTypeEnum['batchSendOffer']!);
      ws?.socket.off(wsMsgTypeEnum['nativeWebRtcOffer']!);
      ws?.socket.off(wsMsgTypeEnum['nativeWebRtcAnswer']!);
      ws?.socket.off(wsMsgTypeEnum['nativeWebRtcCandidate']!);
      ws?.close();
    }
    if (_pc != null) {
      _pc!.close();
      _pc = null;
    }
    if (_stream != null) {
      _stream!.dispose();
      _stream = null;
    }
    if (_remoteRenderer != null) {
      _remoteRenderer!.srcObject = null;
      _remoteRenderer!.dispose();
      _remoteRenderer = null;
    }
    super.dispose();
  }

  handleStream() async {
    try {
      var stream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'mandatory': {
            'facingMode': 'user', // 指定前置摄像头
          },
        },
        'audio': true,
      });
      setState(() {
        _stream = stream;
      });
      handleInitWs();
    } catch (e) {
      billdPrint('handleStream错误', e);
      if (mounted) {
        BrnToast.show('拒绝授权', context);
      }
    }
  }

  handleInitWs() {
    setState(() {
      ws = WsClass();
    });
    ws?.socket.on('connect', (data) {
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
      if (data['receiver'] == ws?.socket.id) {
        billdPrint('是发给我的nativeWebRtcCandidate', data['candidate']);
        RTCIceCandidate iceCandidate =
            RTCIceCandidate(data['candidate']['candidate'], 'label', 0);
        _pc?.addCandidate(iceCandidate);
      }
    });
    ws?.socket.on(wsMsgTypeEnum['nativeWebRtcOffer']!, (data) async {
      if (data['receiver'] == ws?.socket.id) {
        billdPrint('是发给我的nativeWebRtcOffer');
        _pc = await createPeerConnection({});
        setState(() {
          receiver = data['sender'];
        });

        if (_pc != null) {
          _pc!.onTrack = (RTCTrackEvent event) async {
            if (event.track.kind == 'video') {
              var rtcvideo = RTCVideoRenderer();
              await rtcvideo.initialize();
              for (var stream in event.streams) {
                rtcvideo.srcObject = stream;
              }
              setState(() {
                _remoteRenderer = rtcvideo;
              });
            }
          };
          _pc!.onIceCandidate = (RTCIceCandidate event) {
            sendNativeWebRtcCandidate({
              'candidate': event.candidate,
              'sdpMid': event.sdpMid,
              'sdpMLineIndex': event.sdpMLineIndex,
            }, receiver);
          };
        }
        if (_stream != null) {
          _stream?.getTracks().forEach((track) async {
            await _pc?.addTrack(track, _stream!);
          });
          RTCSessionDescription offer =
              RTCSessionDescription(data['sdp']['sdp'], data['sdp']['type']);
          await _pc?.setRemoteDescription(offer);
          var answerSdp = await _pc?.createAnswer();
          if (answerSdp != null) {
            await _pc?.setLocalDescription(answerSdp);
            sendNativeWebRtcAnswer(
                {'type': answerSdp.type, 'sdp': answerSdp.sdp}, data['sender']);
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

  sendNativeWebRtcAnswer(sdp, receiver) {
    ws?.send(wsMsgTypeEnum['nativeWebRtcAnswer']!, billdGetRandomString(8), {
      'live_room_id': liveRoomId,
      'sender': ws?.socket.id,
      'receiver': receiver,
      'sdp': sdp,
    });
  }

  sendBatchSendOffer() {
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
      setState(() {});
      await res.initialize();
      await res.play();
      _controller = res;
      var res2 = computedBox(
          width: res.value.size.width,
          height: res.value.size.height,
          maxWidth: videoWidth,
          minWidth: videoWidth,
          maxHeight: videoHeight,
          minHeight: videoHeight);
      videoBox['width'] = res2['width'];
      videoBox['height'] = res2['height'];
      videoRatio = res.value.size.aspectRatio;
      setState(() {
        loading = false;
      });
    } catch (e) {
      billdPrint('播放错误', e);
      if (mounted) {
        BrnToast.show('播放错误', context, duration: const Duration(seconds: 1));
      }
    }
  }

  stopVideo() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  getData() async {
    var res;
    var err = false;
    try {
      var res =
          await LiveApi.getliveRoomOnlineUser({'live_room_id': liveRoomId});
      if (res['code'] == 200) {
        setState(() {
          onlineUserList = res['data'];
        });
      } else {
        err = true;
      }
    } catch (e) {
      billdPrint('getData错误', e);
      err = true;
    }
    if (err && mounted) {
      var errmsg = res?['message'];
      errmsg ??= networkErrorMsg;
      BrnToast.show(errmsg, context);
    }
  }

  loopGetliveRoomOnlineUser() {
    onlineUserTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      getData();
    });
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
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
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
          Container(
            color: Colors.white,
            width: videoWidth,
            height: videoHeight,
            alignment: Alignment.center, // 垂直和水平居中
            child: showRtc
                ? Container(
                    child: _remoteRenderer != null
                        ? RTCVideoView(
                            _remoteRenderer!,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitContain,
                          )
                        : const Text(
                            '加载中...',
                            style: TextStyle(color: themeColor),
                          ),
                  )
                : Container(
                    child: _controller != null
                        ? SizedBox(
                            width: videoBox['width'],
                            height: videoBox['height'],
                            child: VideoPlayer(_controller!),
                          )
                        : const Text(
                            '加载中...',
                            style: TextStyle(color: themeColor),
                          ),
                  ),
          ),
          BrnTabBar(
            tabs: tabs,
            // tabWidth: 100,
            controller: tabController,
            backgroundcolor: const Color.fromRGBO(12, 22, 34, 1),
            unselectedLabelColor: Colors.white,
            indicatorColor: themeColor,
            labelColor: themeColor,
            mode: BrnTabBarBadgeMode.origin,
            onTap: (state, index) {
              billdPrint(state, index);
              setState(() {
                tabIndex = index;
              });
            },
          ),
          tabIndex == 0 ? Container() : Container(),
          tabIndex == 1
              ? Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '名称：',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          liveRoomInfo['name'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '简介：',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          liveRoomInfo['desc'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          '分区：',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          liveRoomInfo['areas']?[0]?['name'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    )
                  ],
                )
              : Container(),
          tabIndex == 2
              ? onlineUserList.isEmpty
                  ? const Text(
                      '暂无',
                      style: TextStyle(color: Colors.white),
                    )
                  : Column(
                      children: [
                        ...onlineUserList.map((item) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Row(
                              children: [
                                item['value']?['userInfo'] == null
                                    ? Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 5, 0),
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: themeColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                      )
                                    : Container(
                                        width: 30,
                                        height: 30,
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 5, 0),
                                        child: CircleAvatar(
                                          backgroundImage: billdNetworkImage(
                                              item['value']?['userInfo']
                                                      ?['avatar'] ??
                                                  ''),
                                        )),
                                item['value']?['userInfo'] == null
                                    ? Text(
                                        item['value']['socketId'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    : Text(
                                        item['value']?['userInfo']
                                                ?['username'] ??
                                            '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                              ],
                            ),
                          );
                        })
                      ],
                    )
              : Container()
        ],
      ),
    )));
  }
}
