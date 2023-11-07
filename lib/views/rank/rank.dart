import 'package:billd_live_flutter/components/Loading/index.dart';
import 'package:flutter/material.dart';

class Rank extends StatelessWidget {
  const Rank({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('排行');
    // return Container(
    //   child: Column(children: [
    //     ElevatedButton(
    //       child: Text('Show'),
    //       onPressed: () {
    //         print('eeee');
    //       },
    //     ),
    //     ElevatedButton(
    //       child: Text('Show Loading'),
    //       onPressed: () {
    //         BilldLoading.showLoading(context);
    //         // 模拟加载过程
    //         Future.delayed(Duration(seconds: 1), () {
    //           BilldLoading.stop();
    //         });
    //       },
    //     )
    //   ]),
    // );
  }
}
