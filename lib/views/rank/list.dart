import 'package:billd_live_flutter/main.dart';
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
  @override
  Widget build(BuildContext context) {
    List<dynamic> list = widget.list;

    handleZero(int num) {
      if (num < 10) {
        return '0$num';
      }
      return num;
    }

    return ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              color: index % 2 == 0
                  ? Colors.white
                  : const Color.fromRGBO(250, 251, 252, 1),
              child: Row(
                children: [
                  Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(132, 249, 218, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: 55,
                      height: 22,
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Center(
                        child: Text(
                          '${handleZero(index + 3)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                      )),
                  list[index]['user_avatar'] != ''
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(list[index]['user_avatar']),
                          ))
                      : Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    width: 150,
                    child: Text(
                      list[index]['user_username'],
                      style: const TextStyle(
                          fontSize: 12, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  list[index]['live'] != null
                      ? Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: themeColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                          child: Container(
                              transform: Matrix4.translationValues(0, -1, 0),
                              child: const Text(
                                '直播中',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor),
                              )),
                        )
                      : Container()
                ],
              ),
            ),
            onTap: () {
              if (list[index]['live'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Room(
                      hlsurl: list[index]['hls_url'],
                      avatar: list[index]['user_avatar'],
                      username: list[index]['user_username'],
                    ),
                  ),
                );
              } else {
                BrnToast.show('当前房间未在直播', context);
              }
            },
          );
        });
  }
}