import 'package:billd_live_flutter/api/live_room_api.dart';
import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/rank/list.dart';
import 'package:billd_live_flutter/views/rank/top_item.dart';
import 'package:billd_live_flutter/views/room/websocket.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

class Rank extends StatefulWidget {
  const Rank({super.key});

  @override
  State<StatefulWidget> createState() => RankState();
}

const one = Color.fromRGBO(255, 103, 68, 1);
const two = Color.fromRGBO(68, 214, 255, 1);
const three = Color.fromRGBO(255, 178, 0, 1);

class RankState extends State<Rank> {
  final Controller store = Get.put(Controller());

  Map<String, dynamic> liveroomdata = {};
  var topdata = [];
  var otherdata = [];

  var err = false;
  var loading = false;
  var nowPage = 1;
  var pageSize = 50;

  @override
  void initState() {
    super.initState();
    getData();
    handleAudio();
  }

  handleAudio() async {
    // try {
    //   const channel = const MethodChannel("your_channel_name");
    //   // 通过渠道，调用原生代码代码的方法
    //   Future future =
    //       channel.invokeMethod("your_method_name", {"msg": 'd44ty43y3'});
    //   // 打印执行的结果
    //   billdPrint('打印执行的结果');
    //   billdPrint(future.toString());
    // } on PlatformException catch (e) {
    //   billdPrint(e.toString());
    // }
  }

  getData() async {
    var res;
    try {
      setState(() {
        loading = true;
      });
      res = await LiveRoomApi.getLiveRoomList({
        'orderName': 'updated_at',
        'orderBy': 'desc',
        'nowPage': nowPage,
        'pageSize': pageSize
      });
      if (res['code'] == 200) {
        setState(() {
          liveroomdata = res['data'];
          topdata = res['data']['rows'].sublist(0, 3);
          otherdata = res['data']['rows'].sublist(3);
        });
      } else {
        err = true;
      }
    } catch (e) {
      billdPrint(e);
      setState(() {
        err = true;
      });
    }
    setState(() {
      loading = false;
    });
    var msg = res?['message'];
    if (msg is String) {
      BrnToast.show(msg, context);
    } else {
      BrnToast.show(networkErrorMsg, context);
    }
  }

  Future<MediaStream> createMediaStream() async {
    var mediaStream = await createLocalMediaStream('ddd');
    // var audioTrack = MediaStreamTrack();
    // mediaStream.addTrack(audioTrack);
    return mediaStream;
  }

  Future<bool> startForegroundService() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: 'Title of the notification',
      notificationText: 'Text of the notification',
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: androidConfig);
    return FlutterBackground.enableBackgroundExecution();
  }

  @override
  Widget build(BuildContext context) {
    if (err) {
      return const Text(
        '排行榜数据加载失败',
        style: TextStyle(
          fontSize: 20,
        ),
      );
    }
    final size = MediaQuery.of(context).size;
    var topHeight = 290.0;
    var h = size.height -
        kBottomNavigationBarHeight -
        store.safeHeight.value -
        topHeight;
    if (loading) {
      return fullLoading();
    }
    return RefreshIndicator(
      child: Column(children: [
        Container(
          alignment: Alignment.center,
          height: topHeight,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                    child: TopItem(
                      rankNum: NumEnum.two,
                      item: topdata[1],
                    )),
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: TopItem(
                      rankNum: NumEnum.one,
                      item: topdata[0],
                    )),
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                    child: TopItem(
                      rankNum: NumEnum.three,
                      item: topdata[2],
                    )),
              ]),
        ),
        SizedBox(
            height: h,
            child: RankList(
              list: otherdata,
            ))
      ]),
      onRefresh: () async {
        await getData();
        if (context.mounted) {
          BrnToast.show('刷新成功', context);
        }
      },
    );
  }
}
