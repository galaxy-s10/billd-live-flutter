import 'dart:convert';

import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui' as ui;

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // appBar: AppBar(title: const Text('首页')),
      body: HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<StatefulWidget> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  final Controller store = Get.put(Controller());
  var livedata = {};
  VideoPlayerController? _controller;
  int currentItemIndex = 0;
  double aspectRatio = 1.0;
  var memoryImage;

  @override
  initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res = await LiveApi.getLiveList();
    if (res['code'] == 200) {
      play(res['data']['rows'][0]['live_room']['hls_url']);
      var str = res['data']['rows'][0]['live_room']['cover_img'];
      if (str != null) {
        str = str.split(',')[1];
      }
      var imageBytes = base64.decode(str);
      setState(() {
        livedata = res['data'];
        memoryImage = MemoryImage(imageBytes);
      });
    }
  }

  play(String url) async {
    String newurl = url.replaceAll('localhost', '192.168.1.102');
    var res = VideoPlayerController.networkUrl(Uri.parse(newurl),
        videoPlayerOptions: VideoPlayerOptions());
    await res.initialize();
    await res.play();
    setState(() {
      _controller = res;
      aspectRatio = res.value.aspectRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    await play(livedata['rows'][index]['live_room']['hls_url']);
                    var str = livedata['rows'][index]['live_room']['cover_img'];
                    if (str != null) {
                      str = str.split(',')[1];
                    }
                    var imageBytes = base64.decode(str);
                    setState(() {
                      currentItemIndex = index;
                      memoryImage = MemoryImage(imageBytes);
                    });
                  }),
            ),
          ),
        ));
  }
}
