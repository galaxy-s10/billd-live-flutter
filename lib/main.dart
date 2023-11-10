import 'dart:async';

import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/views/home/home.dart';
import 'package:billd_live_flutter/views/live/live.dart';
import 'package:billd_live_flutter/views/rank/rank.dart';
import 'package:billd_live_flutter/views/area/area.dart';
import 'package:billd_live_flutter/views/user/user.dart';
import 'package:bruno/bruno.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

const localIp = '192.168.1.103';
const appTitle = 'billd直播';
const themeColor = Color.fromRGBO(255, 215, 0, 1);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Controller store = Get.put(Controller());
    store.setScreenWidth(size.width);

    return GetMaterialApp(
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
  final Controller store = Get.put(Controller());
  var currentTabIndex = 1;
  var exitTimer = false;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.paddingOf(context);
    store.setSafeHeight(padding.top);
    return WillPopScope(
        child: Scaffold(
            // appBar: AppBar(title: const Text(appTitle)),
            bottomNavigationBar: Visibility(
                visible: store.bottomNavVisible.isTrue,
                child: BottomNavigationBar(
                    items: [
                      createBarItem('home', '首页'),
                      createBarItem('area', '分区'),
                      createBarItem('rank', '排行'),
                      createBarItem('user', '我的'),
                    ],
                    currentIndex: currentTabIndex,
                    onTap: (int index) {
                      print('切换tab,$index');
                      store.setTabIndex(index);
                      setState(() {
                        currentTabIndex = index;
                      });
                    },
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 14,
                    unselectedFontSize: 14,
                    selectedItemColor: themeColor)),
            body: SafeArea(
                child: IndexedStack(
              index: currentTabIndex,
              children: [
                Home(
                  currentIndex: currentTabIndex,
                ),
                const Area(),
                const Rank(),
                const User(),
                const Live()
              ],
            ))),
        onWillPop: () async {
          if (exitTimer == true) {
            setState(() {
              exitTimer = false;
            });
            return true;
          } else {
            BrnToast.show('再按一次退出$appTitle', context);
            setState(() {
              exitTimer = true;
            });
            Timer.periodic(const Duration(seconds: 2), (timer) {
              setState(() {
                exitTimer = false;
              });
            });
            return false;
          }
        });
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
