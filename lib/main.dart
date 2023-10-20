import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const appTitle = 'billd直播';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NavBarWidget(),
    );
  }
}

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return NavBarState();
  }
}

class NavBarState extends State<NavBarWidget> {
  var _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(appTitle)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: 20,
                height: 20,
              ),
              label: '首页'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/tag.png',
                width: 20,
                height: 20,
              ),
              label: '分类'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/trophy.png',
                width: 20,
                height: 20,
              ),
              label: '排行'),
          // BottomNavigationBarItem(
          //     icon: Image.asset(
          //       'assets/images/user.png',
          //       width: 20,
          //       height: 20,
          //     ),
          //     label: '我的'),
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          _currentIndex = index;
          // print(index);
        },
        // selectedFontSize: 20,
        // unselectedFontSize: 10,
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        appTitle,
      )),
      body: Column(children: [
        const Text('hello'),
        Image.network(
            'https://resource.hsslive.cn/image/9218d742cac57c00428e94fb7784ad32.jpg')
      ]),
    );
  }
}
