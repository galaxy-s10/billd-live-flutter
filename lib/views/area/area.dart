import 'package:billd_live_flutter/api/area_api.dart';
import 'package:billd_live_flutter/views/area/area_item.dart';

import 'package:flutter/material.dart';

late BuildContext gcontext; //全局变量 由内部 WidgetsBinding赋值

class Area extends StatelessWidget {
  const Area({super.key});

  @override
  Widget build(BuildContext context) {
    return const AreaBody();
  }
}

class AreaBody extends StatefulWidget {
  const AreaBody({super.key});

  @override
  State<StatefulWidget> createState() => AreaBodyState();
}

class AreaBodyState extends State<AreaBody> {
  Map<String, dynamic> list = {};

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在Widget构建完成后执行代码
      BuildContext gcontext = context;
      // 在这里可以使用context
      print('Context: $context');
    });
    print('initState-area');
    getList();
  }

  getList() async {
    try {
      var res = await AreaApi.getAreaAreaLiveRoomList();
      setState(() {
        list = res['data'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: list['total'],
        itemBuilder: (context, index) {
          if (list.isNotEmpty) {
            return AreaItemWidget(list["rows"][index]);
          }
          return null;
        });
  }
}
