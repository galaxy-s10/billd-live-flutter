import 'dart:convert';
import 'dart:ui' as ui;

import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/main.dart';
import 'package:billd_live_flutter/stores/app.dart';

import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

VideoPlayerController? _controller;
double _aspectRatio = 16 / 9;
var memoryImage;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {
  final Controller store = Get.put(Controller());
  var livedata = {};
  ValueNotifier<int> currentItemIndex = ValueNotifier(0);
  bool loading = false;

  @override
  initState() {
    print('initState-home${store.tabIndex}');
    super.initState();
    getData().then((_) {
      if (store.tabIndex.value == 0) {
        playVideo(
            livedata['rows'][currentItemIndex.value]['live_room']['hls_url']);
      }
    });
    store.tabIndex.listen((value) async {
      if (value != 0) {
        await stopVideo();
      } else {
        await playVideo(
            livedata['rows'][currentItemIndex.value]['live_room']['hls_url']);
      }
    });
    currentItemIndex.addListener(() async {
      await playVideo(
          livedata['rows'][currentItemIndex.value]['live_room']['hls_url']);
    });
  }

  Future getData() async {
    var res = await LiveApi.getLiveList();
    if (res['code'] == 200) {
      setState(() {
        livedata = res['data'];
      });
    }
  }

  playVideo(String url) async {
    try {
      await stopVideo();
      String newurl = url.replaceAll('localhost', localIp);
      var res = VideoPlayerController.networkUrl(Uri.parse(newurl),
          videoPlayerOptions: VideoPlayerOptions());
      _controller = res;
      memoryImage = hanldeMemoryImage(currentItemIndex.value);
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
    setState(() {
      loading = true;
    });
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
      }
      return MemoryImage(base64.decode(str));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (livedata['rows'] != null && store.tabIndex.value == 0) {
      final size = MediaQuery.of(context).size;
      double height =
          size.height - kBottomNavigationBarHeight - store.safeHeight.value;
      return Container(
          decoration: memoryImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                  image: memoryImage,
                  fit: BoxFit.cover,
                ))
              : const BoxDecoration(color: Colors.black),
          width: store.screenWidth.value,
          height: height,
          child: ClipRect(
            child: BackdropFilter(
              filter:
                  ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 设置模糊效果的程度
              child: CarouselSlider.builder(
                itemCount: livedata.isNotEmpty ? livedata['total'] : 0,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  if (_controller != null && livedata['rows'] != null) {
                    return Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: loading
                              ? const Text(
                                  '加载中...',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: 20,
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio: _aspectRatio,
                                  child: VideoPlayer(_controller!),
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            margin: const EdgeInsets.fromLTRB(6, 0, 0, 6),
                            child: Text(
                              '${livedata['rows'][currentItemIndex.value]['live_room']['name']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  return Container();
                },
                options: CarouselOptions(
                    height: height,
                    autoPlay: false,
                    enlargeCenterPage: false,
                    viewportFraction: 1,
                    scrollDirection: Axis.vertical,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 300),
                    onPageChanged: (index, reason) async {
                      setState(() {
                        currentItemIndex.value = index;
                      });
                    }),
              ),
            ),
          ));
    } else {
      return Container();
    }
  }
}
