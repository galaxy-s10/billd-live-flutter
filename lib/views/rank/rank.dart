import 'package:billd_live_flutter/api/live_room_api.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/rank/list.dart';
import 'package:billd_live_flutter/views/rank/top_item.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
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

  var liveroomdata = {};
  var topdata = [];
  var otherdata = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res;
    bool err = false;
    try {
      res = await LiveRoomApi.getLiveRoomList(
          {'orderName': 'updated_at', 'orderBy': 'desc'});
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
      print(e);
    }
    if (err && context.mounted) {
      BrnToast.show(res['message'], context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var topHeight = 290.0;
    var h = size.height -
        kBottomNavigationBarHeight -
        store.safeHeight.value -
        topHeight;

    if (liveroomdata.isEmpty) {
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
