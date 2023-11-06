// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// class MyContainerWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/images/background.jpg'),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';

void main() {
  var random = Random();

  // 生成随机整数
  int randomInt = random.nextInt(100); // 生成0到99之间的随机整数
  print('随机整数: $randomInt');

  // 生成随机双精度浮点数
  String randomDouble = random.nextDouble().toString(); // 生成0.0到1.0之间的随机双精度浮点数

  print('随机双精度浮点数: ${randomDouble}');
  print('随机双精度浮点数: ${randomDouble.substring(2)}');
}
