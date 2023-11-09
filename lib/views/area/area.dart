import 'package:billd_live_flutter/api/area_api.dart';
import 'package:billd_live_flutter/views/area/area_item.dart';

import 'package:flutter/material.dart';

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
    return Container(
      color: const Color(0xFFF4F4F4),
      child: ListView.builder(
          itemCount: list['total'],
          itemBuilder: (context, index) {
            if (list.isNotEmpty) {
              return AreaItemWidget(
                item: list["rows"][index],
              );
            }
            return null;
          }),
    );
  }
}
