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

class Home extends StatelessWidget {
  final int currentIndex;
  const Home({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return HomeBody(
      currentIndex: currentIndex,
    );
  }
}

class HomeBody extends StatefulWidget {
  final int currentIndex;
  const HomeBody({required this.currentIndex, super.key});

  @override
  State<StatefulWidget> createState() => HomeBodyState(currentIndex);
}

class HomeBodyState extends State<HomeBody> {
  final Controller store = Get.put(Controller());
  var livedata = {};
  VideoPlayerController? _controller;
  int currentItemIndex = 0;
  double aspectRatio = 1.0;
  bool loading = false;

  var memoryImage;

  HomeBodyState(int currentIndex);

  @override
  initState() {
    print('initState-home');
    super.initState();
    getData();
  }

  getData() async {
    var res = await LiveApi.getLiveList();
    if (res['code'] == 200) {
      List<dynamic> rows = res['data']['rows'];
      if (rows.isNotEmpty) {
        var first = rows[0];
        var res1 = await play(first['live_room']['hls_url']);
        if (res1 != null) {
          setState(() {
            _controller = res1;
            aspectRatio = res1.value.aspectRatio;
            livedata = res['data'];
            var imageBytes = hanldeMemoryImage(0);
            if (imageBytes != null) {
              memoryImage = MemoryImage(imageBytes);
            }
          });
        }
      }
    }
  }

  play(String url) async {
    try {
      stopVideo();
      String newurl = url.replaceAll('localhost', localIp);
      var res = VideoPlayerController.networkUrl(Uri.parse(newurl),
          videoPlayerOptions: VideoPlayerOptions());
      await res.initialize();
      await res.play();
      return res;
    } catch (e) {
      print(e);
      BrnToast.show('播放错误', context);
    }
  }

  stopVideo() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  hanldeMemoryImage(index) {
    if (livedata['rows'] != null) {
      var str = livedata['rows'][index]['live_room']['cover_img'];
      if (str != null) {
        str = str.split(',')[1];
      }
      return base64.decode(str);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (store.tabIndex.value != 0) {
      stopVideo();
    }
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
        width: size.width,
        height: height,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // 设置模糊效果的程度
            child: CarouselSlider.builder(
              itemCount: livedata.isNotEmpty ? livedata['total'] : 0,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                if (_controller != null &&
                    livedata['rows'] != null &&
                    currentItemIndex == itemIndex) {
                  return Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            livedata['rows'][itemIndex]['live_room']['name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      )
                    ],
                  );
                }
                return Stack(children: [
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
                          : null)
                ]);
              },
              options: CarouselOptions(
                  height: height,
                  autoPlay: false,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  scrollDirection: Axis.vertical,
                  autoPlayAnimationDuration: const Duration(milliseconds: 300),
                  onPageChanged: (index, reason) async {
                    try {
                      setState(() {
                        loading = true;
                      });
                      var res = await play(
                          livedata['rows'][index]['live_room']['hls_url']);
                      if (res != null) {
                        setState(() {
                          loading = false;
                          _controller = res;
                          aspectRatio = res.value.aspectRatio;
                          currentItemIndex = index;
                          var imageBytes = hanldeMemoryImage(index);
                          if (imageBytes != null) {
                            memoryImage = MemoryImage(imageBytes);
                          }
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                    }
                  }),
            ),
          ),
        ));
  }
}
