import 'dart:async';

import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/utils/index.dart';
import 'package:billd_live_flutter/views/home/home.dart';
import 'package:billd_live_flutter/views/live/live.dart';
import 'package:billd_live_flutter/views/rank/rank.dart';
import 'package:billd_live_flutter/views/area/area.dart';
import 'package:billd_live_flutter/views/user/user.dart';
import 'package:bruno/bruno.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
  var currentTabIndex = 2;
  var exitTimer = false;
  var exitDelay = 1;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.of(context).size;
    var normalHeight =
        size.height - kBottomNavigationBarHeight - store.safeHeight.value;
    store.setNormalHeight(normalHeight);
    store.setSafeHeight(padding.top);
    store.setTabIndex(currentTabIndex);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (exitTimer == true) {
          setState(() {
            exitTimer = false;
          });
          SystemNavigator.pop();
        } else {
          BrnToast.show('再按一次退出$appTitle', context,
              duration: Duration(seconds: exitDelay));
          setState(() {
            exitTimer = true;
          });
          Future.delayed(Duration(seconds: exitDelay), () {
            if (mounted) {
              setState(() {
                exitTimer = false;
              });
            }
          });
        }
      },
      child: Stack(
        children: [
          Scaffold(
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
                children: const [Home(), Area(), Rank(), User(), Live()],
              ))),
          axiosBaseUrl.contains('hsslive') == false
              ? const Positioned(
                  bottom: 55,
                  right: 10,
                  child: IgnorePointer(
                    child: Text(
                      'beta',
                      style: TextStyle(
                          color: themeColor,
                          fontSize: 14,
                          decoration: TextDecoration.none),
                    ),
                  ))
              : Container()
        ],
      ),
    );
  }
}

BottomNavigationBarItem createBarItem(String iconName, String label) {
  return BottomNavigationBarItem(
      icon: Image.asset(
        "assets/images/tabbar/$iconName.png",
        width: 20,
      ),
      activeIcon: Image.asset(
        "assets/images/tabbar/${iconName}_active.png",
        width: 20,
      ),
      label: label);
}
