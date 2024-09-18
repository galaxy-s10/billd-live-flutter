import 'package:billd_live_flutter/api/live_room_api.dart';
import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/rank/list.dart';
import 'package:billd_live_flutter/views/rank/top_item.dart';
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
  initState() {
    super.initState();
    getData();
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
          err = false;
          liveroomdata = res['data'];
          topdata = res['data']['rows'].sublist(0, 3);
          otherdata = res['data']['rows'].sublist(3);
        });
      } else {
        setState(() {
          err = true;
        });
      }
    } catch (e) {
      billdPrint('getData错误', e);
      setState(() {
        err = true;
      });
    }
    setState(() {
      loading = false;
    });
    if (err && mounted) {
      var errmsg = res?['message'];
      errmsg ??= networkErrorMsg;
      BrnToast.show(
        errmsg,
        context,
      );
    }
  }

  refreshData() async {
    await getData();
  }

  @override
  Widget build(BuildContext context) {
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
        child: err
            ? ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return const Text('排行榜数据加载错误');
                })
            : ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Column(children: [
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
                  ]);
                }),
        onRefresh: () async {
          await refreshData();
          if (context.mounted) {
            BrnToast.show('刷新成功', context,
                duration: const Duration(seconds: 1));
          }
        });
  }
}
