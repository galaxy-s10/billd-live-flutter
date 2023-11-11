import 'dart:convert';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AreaItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final Controller store = Get.put(Controller());

  AreaItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    var w = (store.screenWidth.value / 2) - 20;
    var h = w / (16 / 9);

    var coverImg = item['cover_img'];
    var avatar = item['users'][0]['avatar'];
    if (coverImg != null) {
      coverImg = coverImg.split(',')[1];
    }
    return Column(
      children: [
        SizedBox(
            width: w,
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
            )),
        Container(
          width: w,
          alignment: Alignment.centerLeft,
          child: Text(
            item['name'],
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
