import 'package:billd_live_flutter/api/area_api.dart';
import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/area/area_item.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AreaList extends StatefulWidget {
  final int id;
  final String areaName;
  const AreaList({required this.id, required this.areaName, super.key});

  @override
  State<StatefulWidget> createState() => AreaListState();
}

class AreaListState extends State<AreaList> {
  List<dynamic> list = [];
  final Controller store = Get.put(Controller());

  var id = -1;
  var areaName = '';
  var hasMore = true;
  var loading = false;
  var nowPage = 1;
  var pageSize = 50;
  bool err = true;

  final ScrollController _controller = ScrollController();

  @override
  initState() {
    id = widget.id;
    areaName = widget.areaName;
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!hasMore) return;
        nowPage += 1;
        getData();
      }
    });

    super.initState();
    getData();
  }

  getData() async {
    var res;
    try {
      setState(() {
        loading = true;
      });
      res = await AreaApi.getAreaLiveRoomList(id, nowPage, pageSize);
      if (res['code'] == 200) {
        setState(() {
          err = false;
          hasMore = res['data']['hasMore'];
          list.addAll(res['data']['rows']);
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
      BrnToast.show(errmsg, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var titleHeight = 40.0;
    var h = size.height - store.safeHeight.value - titleHeight;
    return Scaffold(
        body: SafeArea(
            child: RefreshIndicator(
      child: Column(
        children: [
          Container(
            height: titleHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              '$areaName分区',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          SizedBox(
            height: h,
            child: ListView.builder(
                controller: _controller,
                itemCount: 1,
                itemBuilder: (context, index) {
                  var len = list.length;
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Column(
                      children: [
                        GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            // Item的宽高比，由于GridView的Item宽高并不由Item自身控制，默认情况下，交叉轴是横轴，因此Item的宽度均分屏幕宽度，这个时候设置childAspectRatio可以改变Item的高度，反之亦然；
                            childAspectRatio: (normalVideoRatio) * 0.8,
                            children: List.generate(len, (indey) {
                              var res = list[indey];
                              return res == null
                                  ? Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                      child: const Text('暂无数据'),
                                    )
                                  : AreaItemWidget(
                                      item: res,
                                    );
                            })),
                        loading == true ? const Text('加载中...') : Container(),
                        hasMore == false
                            ? const Text(
                                '已加载所有',
                              )
                            : Container(),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      onRefresh: () async {
        nowPage = 1;
        await getData();
        if (context.mounted) {
          BrnToast.show('刷新成功', context, duration: const Duration(seconds: 1));
        }
      },
    )));
  }
}
