import 'package:billd_live_flutter/api/area_api.dart';
import 'package:billd_live_flutter/views/area/area_item.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class AreaList extends StatefulWidget {
  final id;
  const AreaList({required this.id, super.key});

  @override
  State<StatefulWidget> createState() => AreaListState(id);
}

class AreaListState extends State<AreaList> {
  Map<String, dynamic> areadata = {};

  var id;

  @override
  void initState() {
    super.initState();
    getData();
  }

  AreaListState(this.id);

  getData() async {
    var res;
    bool err = false;
    try {
      res = await AreaApi.getAreaLiveRoomList(id);
      if (res['code'] == 200) {
        setState(() {
          areadata = res['data'];
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
    return Scaffold(
        body: SafeArea(
            child: areadata['rows'] == null || areadata['rows'].length == 0
                ? Center(
                    child: Text(areadata['rows'] == null ? '正在加载...' : '暂无数据'),
                  )
                : ListView.builder(
                    itemCount: areadata['total'],
                    itemBuilder: (context, index) {
                      var len = areadata["rows"].length;
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Column(
                          children: [
                            len == 0
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                    child: const Text('暂无数据'),
                                  )
                                : GridView.count(
                                    crossAxisCount: 2,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 0,
                                    // Item的宽高比，由于GridView的Item宽高并不由Item自身控制，默认情况下，交叉轴是横轴，因此Item的宽度均分屏幕宽度，这个时候设置childAspectRatio可以改变Item的高度，反之亦然；
                                    childAspectRatio: (16 / 9) * 0.8,
                                    children: List.generate(len, (indey) {
                                      var res = areadata["rows"][indey];
                                      return res == null
                                          ? Container(
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 2, 0, 2),
                                              child: const Text('暂无数据'),
                                            )
                                          : AreaItemWidget(
                                              item: res,
                                            );
                                    })),
                          ],
                        ),
                      );
                    })));
  }
}
