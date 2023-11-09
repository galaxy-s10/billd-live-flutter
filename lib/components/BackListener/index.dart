import 'package:flutter/material.dart';

class BackListener extends StatelessWidget {
  final Widget child;
  final Function() onBack;

  const BackListener({required this.child, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Text('4444');
    // return WillPopScope(
    //   onWillPop: () async {
    //     print('返回了11111');
    //     onBack();
    //     return false;
    //   },
    //   child: child,
    // );
  }
}
