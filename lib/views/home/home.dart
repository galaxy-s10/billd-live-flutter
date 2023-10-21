import 'package:billd_live_flutter/api/request.dart';
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
  @override
  initState() {
    super.initState();
    HttpRequest.get('/live/list', params: {});
  }

  @override
  Widget build(BuildContext context) {
    initState();
    return Text('d');
  }
}
