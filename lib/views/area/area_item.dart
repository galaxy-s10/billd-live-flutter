import 'package:flutter/material.dart';

class AreaItemWidget extends StatelessWidget {
  AreaItemWidget(this.item, {super.key});
  Map<String, dynamic> item = {};

  @override
  Widget build(BuildContext context) {
    print('--------');
    print(item);
    print('--------');
    return Text(item['name']);
  }
}
