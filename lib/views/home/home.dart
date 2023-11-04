import 'dart:convert';

import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;

class Home extends StatelessWidget {
  Home(this.currentIndex, {super.key});
  var currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('33ddddddd');
    return Scaffold(
      // appBar: AppBar(title: const Text('首页')),
      body: HomeBody(currentIndex),
    );
  }
}

class HomeBody extends StatefulWidget {
  HomeBody(this.currentIndex, {super.key});
  var currentIndex = 0;

  @override
  State<StatefulWidget> createState() => HomeBodyState(currentIndex);
}

class HomeBodyState extends State<HomeBody> {
  final Controller store = Get.put(Controller());
  var livedata = {};
  VideoPlayerController? _controller;
  int currentItemIndex = 0;
  double aspectRatio = 1.0;

  var memoryImage;

  HomeBodyState(int currentIndex);

  @override
  initState() {
    super.initState();
    getData();
  }

  // @override
  // dispose() {
  //   print('disposedispose');
  //   super.dispose();
  // }

  getData() async {
    var res = await LiveApi.getLiveList();
    if (res['code'] == 200) {
      var res1 = await play(res['data']['rows'][0]['live_room']['hls_url']);
      var str = res['data']['rows'][0]['live_room']['cover_img'];
      if (str != null) {
        str = str.split(',')[1];
      }
      var imageBytes = base64.decode(str);
      setState(() {
        _controller = res1;
        aspectRatio = res1.value.aspectRatio;
        livedata = res['data'];
        memoryImage = MemoryImage(imageBytes);
      });
    }
  }

  play(String url) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    String newurl = url.replaceAll('localhost', '192.168.1.102');
    var res = VideoPlayerController.networkUrl(Uri.parse(newurl),
        videoPlayerOptions: VideoPlayerOptions());
    await res.initialize();
    await res.play();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (store.tabIndex.value != 0 && _controller != null) {
      _controller!.dispose();
      _controller = null;
    } else {
      if (livedata.length != 0 && currentItemIndex != null) {
        // print('kkkkkkk');
        // play(livedata['rows'][currentItemIndex]['live_room']['hls_url']);
      }
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
                return Container();
              },
              options: CarouselOptions(
                  height: height,
                  autoPlay: false,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  scrollDirection: Axis.vertical,
                  autoPlayAnimationDuration: const Duration(milliseconds: 300),
                  onPageChanged: (index, reason) async {
                    var res = await play(
                        livedata['rows'][index]['live_room']['hls_url']);
                    var str = livedata['rows'][index]['live_room']['cover_img'];
                    if (str != null) {
                      str = str.split(',')[1];
                    }
                    var imageBytes = base64.decode(str);
                    setState(() {
                      _controller = res;
                      aspectRatio = res.value.aspectRatio;
                      currentItemIndex = index;
                      memoryImage = MemoryImage(imageBytes);
                    });
                  }),
            ),
          ),
        ));
  }
}
