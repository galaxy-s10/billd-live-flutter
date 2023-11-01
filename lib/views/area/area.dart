import 'package:billd_live_flutter/api/area_api.dart';
import 'package:billd_live_flutter/views/area/area_item.dart';
import 'package:flutter/material.dart';

class Area extends StatelessWidget {
  const Area({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分区')),
      body: const AreaBody(),
    );
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
    getList();
  }

  getList() async {
    var res = await AreaApi.getAreaAreaLiveRoomList();
    print('getListgetList');
    print(res.data['data']['total']);
    print(res.data['data']['rows'].length);
    setState(() {
      list = res.data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text(list.length.toString());
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
