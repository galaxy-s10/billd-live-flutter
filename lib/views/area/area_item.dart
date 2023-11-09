import 'dart:convert';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/views/area/list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AreaItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  const AreaItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final Controller store = Get.put(Controller());
    var w = (store.screenWidth / 2) - 20;
    var h = w / (16 / 9);
    var len = item['area_live_rooms'].length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(item['name'])),
            GestureDetector(
              child: const Text(
                '查看全部',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AreaList(),
                  ),
                );
              },
            )
          ]),
        ),
        len == 0
            ? Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: const Text('暂无数据'),
              )
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: (16 / 9) *
                    0.8, //Item的宽高比，由于GridView的Item宽高并不由Item自身控制，默认情况下，交叉轴是横轴，因此Item的宽度均分屏幕宽度，这个时候设置childAspectRatio可以改变Item的高度，反之亦然；
                children: List.generate(
                  len,
                  (index) {
                    var liveRoomInfo =
                        item['area_live_rooms'][index]['live_room'];
                    var coverImg = liveRoomInfo['cover_img'];
                    var avatar = liveRoomInfo['users'][0]['avatar'];
                    if (coverImg != null) {
                      coverImg = coverImg.split(',')[1];
                    }
                    return Column(
                      children: [
                        SizedBox(
                          width: w,
                          height: h,
                          child: coverImg == null
                              ? Image.network(
                                  avatar,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                )
                              : Image.memory(
                                  base64Decode(coverImg),
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(liveRoomInfo['name']),
                        )
                      ],
                    );
                  },
                ))
      ]),
    );
  }
}
