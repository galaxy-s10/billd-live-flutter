import 'dart:async';

import 'package:billd_live_flutter/api/home_api.dart';
import 'package:billd_live_flutter/api/request.dart';
import 'package:billd_live_flutter/models/home_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页22')),
      body: const HomeBody(),
    );
  }
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<StatefulWidget> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  List<String> list = [];
  @override
  initState() {
    super.initState();
    getList();
  }

  getList() async {
    // HttpRequest.get().then((v) {
    var res = await HttpRequest.get();
    print(res.data['code']);

    // Map<String, dynamic> a = {"age": 19, "name": false};
    // Map<String, LiveItem> b = {"age": LiveItem()};
    // a = b;
    // b = a;
    // dynamic aa;
    // LiveItem bb = LiveItem();
    // aa = bb;
    // bb = aa;
    // print(a);
    // print(b);
  }

  @override
  Widget build(BuildContext context) {
    // initState();
    return Text(list.length.toString());
  }
}
