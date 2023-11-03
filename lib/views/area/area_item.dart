import 'package:flutter/material.dart';
import 'dart:convert';

class AreaItemWidget extends StatelessWidget {
  AreaItemWidget(this.item, {super.key});
  Map<String, dynamic> item = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 10, color: Colors.red))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(item['name'])),
          const Text('查看全部')
        ]),
        ListView.builder(
            // Flutter中Column嵌套ListView报错处理方案
            shrinkWrap: true, //范围内进行包裹（内容多高ListView就多高）
            physics: const NeverScrollableScrollPhysics(), //禁止滚动
            itemCount: item['area_live_rooms'].length,
            itemBuilder: (context, index) {
              if (item['area_live_rooms'].length != 0) {
                var str =
                    (item['area_live_rooms'][index]['live_room']['cover_img']);
                if (str != null) {
                  str = str.split(',')[1];
                }
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expanded(
                      //     child: Image.network(
                      //         'https://resource.hsslive.cn/image/9218d742cac57c00428e94fb7784ad32.jpg')),
                      str == null
                          ? const Text('')
                          : Image.memory(
                              base64Decode(str),
                              width: 100,
                              height: 100,
                            ),
                      Text(item['area_live_rooms'][index]['live_room']['name'])
                    ]);
              }
              return null;
            }),
        // Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [Expanded(child: Text(item['name'])), const Text('查看全部')])
      ]),
    );
  }
}
