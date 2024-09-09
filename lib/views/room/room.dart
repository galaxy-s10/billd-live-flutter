import 'dart:async';

import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/enum.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/ws_sdk.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';
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
  final Controller store = Get.put(Controller());
  String flvurl = '';
  String hlsurl = '';
  String avatar = '';
  String username = '';
  int liveRoomId = -1;
  var liveRoomInfo;
  var timer;
  var videoRatio = normalVideoRatio;

  WsClass ws = WsClass();
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    ws.init();
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // ws.send(wsMsgTypeEnum['message']!, billdGetRandomString(8), {});
      sendJoin();
    });
    liveRoomId = widget.liveRoomId;
    liveRoomInfo = widget.liveRoomInfo;
    hlsurl = widget.hlsurl;
    avatar = widget.avatar;
    username = widget.username;

    ws.socket.on(wsMsgTypeEnum['joined']!, (data) {
      if (liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_one'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_two'] ||
          liveRoomInfo['type'] == liveRoomTypeEnum['pk']) {
        sendBatchSendOffer();
      }
    });
    if (liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_one'] ||
        liveRoomInfo['type'] == liveRoomTypeEnum['wertc_meeting_two'] ||
        liveRoomInfo['type'] == liveRoomTypeEnum['pk']) {
      return;
    }
    playVideo(widget.hlsurl);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    stopVideo();
    ws.close();
  }

  sendJoin() {
    billdPrint('sendJoinsendJoin', liveRoomId);
    ws.send(wsMsgTypeEnum['join']!, billdGetRandomString(8), {
      'isBilibili': false,
      'isRemoteDesk': false,
      'live_room_id': liveRoomId,
      'user_info': null,
    });
  }

  sendBatchSendOffer() {
    billdPrint('batchSendOffer', liveRoomId);
    ws.send(wsMsgTypeEnum['batchSendOffer']!, billdGetRandomString(8), {
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
            onTap: () {
              // ws.send('join', billdGetRandomString(8), {
              //   'liveRoomId': 123456,
              //   'socket_id': ws.socket.id,
              //   'isRemoteDesk': true,
              // });
            },
          )
        ],
      ),
    )));
  }
}
