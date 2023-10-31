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
    print(res.data);
    print(res.data.runtimeType);
    print(res.data['data'].runtimeType);
    setState(() {
      list = res.data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text(list.length.toString());
    return ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          print('3333${list["rows"]}');
          print('${list[index]}');
          if (list.length != 0) {
            // print('331111${list}');
            // print('3333${list["rows"]}');
            print('11${list["rows"][index]}');
            return AreaItemWidget(list["rows"][index]);
          }
          // return AreaItemWidget(list[index]);
        });
  }
}
