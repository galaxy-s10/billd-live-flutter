import 'dart:convert';

import 'package:billd_live_flutter/main.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as ws;

class Room extends StatefulWidget {
  final String hlsurl;
  final String avatar;
  final String username;

  const Room({
    required this.hlsurl,
    required this.avatar,
    required this.username,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => RankState();
}

VideoPlayerController? _controller;
double _aspectRatio = 16 / 9;
var memoryImage;

class RankState extends State<Room> {
  var loading = false;
  final Controller store = Get.put(Controller());
  var livedata = {};
  String hlsurl = '';
  String avatar = '';
  String username = '';
  late ws.Socket? socket;

  @override
  void initState() {
    super.initState();
    hlsurl = widget.hlsurl;
    avatar = widget.avatar;
    username = widget.username;
    playVideo(widget.hlsurl);
  }

  @override
  void dispose() {
    super.dispose();
    stopVideo();
    socket?.close();
    socket = null;
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
      memoryImage = hanldeMemoryImage('value');
      setState(() {});
      await res.initialize();
      await res.play();
      _aspectRatio = res.value.aspectRatio;
      setState(() {
        loading = false;
      });
    } catch (e) {
      print(e);
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

  hanldeMemoryImage(index) {
    if (livedata['rows'] != null) {
      var str = livedata['rows'][index]['live_room']['cover_img'];
      if (str != null) {
        str = str.split(',')[1];
        return MemoryImage(base64.decode(str));
      }
    }
    return null;
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
                avatar != ''
                    ? SizedBox(
                        width: 40,
                        height: 40,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                        ))
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
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
                      aspectRatio: _aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(
                      color: Colors.white,
                    )
        ],
      ),
    )));
  }
}
