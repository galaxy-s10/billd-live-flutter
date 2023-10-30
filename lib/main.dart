import 'package:billd_live_flutter/views/home/home.dart';
import 'package:billd_live_flutter/views/rank/rank.dart';
import 'package:billd_live_flutter/views/area/area.dart';
import 'package:billd_live_flutter/views/user/user.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const appTitle = 'billd直播';
const themeColor = Color.fromRGBO(255, 215, 0, 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //右上角的debug信息
      title: appTitle,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: themeColor),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent
          // primaryColor: Colors.red,
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
            createBarItem('home', '首页'),
            createBarItem('area', '分区'),
            createBarItem('rank', '排行'),
            createBarItem('user', '我的'),
          ],
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedItemColor: themeColor),
      body: IndexedStack(
        index: _currentIndex,
        children: const [Home(), Area(), Rank(), User()],
      ),
    );
  }
}

BottomNavigationBarItem createBarItem(String iconName, String lable) {
  return BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/tabbar/$iconName.png",
        width: 20,
      ),
      activeIcon: Image.asset(
        "assets/images/tabbar/${iconName}_active.png",
        width: 20,
      ),
      label: lable);
}
