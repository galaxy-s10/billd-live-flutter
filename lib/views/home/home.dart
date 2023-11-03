import 'package:billd_live_flutter/api/live_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _controller;

  @override
  initState() {
    super.initState();
    getData();
    // play(livedata['rows'][itemIndex]['live_room']['hls_url']);
    play('');
  }

  getData() async {
    var res = await LiveApi.getLiveList();
    print(res);
    if (res['code'] == 200) {
      setState(() {
        livedata = res['data'];
      });
    }
  }

  play(url) {
    print(url);
    print('urlllllll');
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      // Uri.parse('https://srs-pull.hsslive.cn/livestream/roomId___12.m3u8'),
    )..initialize().then((_) {
        print('初始化完成');
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        color: Colors.red,
        width: size.width,
        height:
            size.height - kBottomNavigationBarHeight - store.safeHeight.value,
        // child: Text('32'),
        child: CarouselSlider.builder(
          itemCount: livedata.isNotEmpty ? livedata['total'] : 0,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) {
            print(itemIndex);
            print('kkkkk');
            play(livedata['rows'][itemIndex]['live_room']['hls_url']);
            if (livedata['rows'] != null) {
              print(livedata['rows']);
              print(livedata['rows'][0]);
              return Center(
                  child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ));
            }
            return Container();
          },
          options: CarouselOptions(
            height: 400,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            scrollDirection: Axis.vertical,
            autoPlayAnimationDuration: const Duration(milliseconds: 300),
          ),
        ));
  }
}
