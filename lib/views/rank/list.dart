import 'package:billd_live_flutter/api/live_room_api.dart';
import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/room/room.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';

class RankList extends StatefulWidget {
  final List<dynamic> list;

  const RankList({super.key, required this.list});

  @override
  State<StatefulWidget> createState() => RankListState();
}

class RankListState extends State<RankList> {
  final ScrollController _controller = ScrollController();

  List<dynamic> list = [];

  var loading = false;
  var hasMore = true;
  var nowPage = 2;
  var pageSize = 50;
  bool err = true;

  @override
  initState() {
    list.addAll(widget.list);
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!hasMore) return;
        nowPage += 1;
        getData();
      }
    });

    super.initState();
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
          hasMore = res['data']['hasMore'];
          list.addAll(res['data']['rows']);
        });
      } else {
        setState(() {
          err = true;
        });
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
    if (err && context.mounted) {
      var errmsg = res['message'];
      errmsg ??= networkErrorMsg;
      BrnToast.show(errmsg, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        itemCount: 1,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                Column(
                    children: List.generate(
                  list.length,
                  (indey) {
                    var res = list[indey];
                    var imgurl = res?['users']?[0]?['avatar'];

                    return res == null
                        ? Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: const Text('暂无数据'),
                          )
                        : GestureDetector(
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                color: indey % 2 == 0
                                    ? Colors.white
                                    : const Color.fromRGBO(250, 251, 252, 1),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            decoration: const BoxDecoration(
                                              color: Color.fromRGBO(
                                                  132, 249, 218, 1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            width: 55,
                                            height: 22,
                                            margin: const EdgeInsets.fromLTRB(
                                                10, 0, 10, 0),
                                            child: Center(
                                              child: Text(
                                                '${handleZero(indey + 3)}',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            )),
                                        imgurl == null || imgurl == ''
                                            ? Container(
                                                width: 26,
                                                height: 26,
                                                decoration: const BoxDecoration(
                                                  color: themeColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                              )
                                            : SizedBox(
                                                width: 26,
                                                height: 26,
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      billdNetworkImage(imgurl),
                                                )),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          width: 150,
                                          child: Text(
                                            list[indey]['users'][0]['username'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ),
                                        list[indey]['live'] != null
                                            ? Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: themeColor),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        6, 2, 6, 2),
                                                child: Container(
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0, -1, 0),
                                                    child: const Text(
                                                      '直播中',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: themeColor),
                                                    )),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ],
                                )),
                            onTap: () {
                              if (list[indey]['live'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Room(
                                      liveRoomInfo: list[indey],
                                    ),
                                  ),
                                );
                              } else {
                                BrnToast.show('当前房间未在直播', context);
                              }
                            },
                          );
                  },
                )),
                loading == true
                    ? const Text(
                        '加载中...',
                      )
                    : Container(),
                hasMore == false
                    ? const Text(
                        '已加载所有',
                      )
                    : Container(),
              ],
            ),
          );
        });
  }
}
