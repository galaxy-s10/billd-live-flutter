import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/views/home/home.dart';
import 'package:billd_live_flutter/views/live/rank.dart';
import 'package:billd_live_flutter/views/rank/rank.dart';
import 'package:billd_live_flutter/views/area/area.dart';
import 'package:billd_live_flutter/views/user/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  // Future<bool> startForegroundService() async {
  //   final androidConfig = FlutterBackgroundAndroidConfig(
  //     notificationTitle: 'Title of the notification',
  //     notificationText: 'Text of the notification',
  //     notificationImportance: AndroidNotificationImportance.Default,
  //     notificationIcon: AndroidResource(
  //         name: 'background_icon',
  //         defType: 'drawable'), // Default is ic_launcher from folder mipmap
  //   );
  //   await FlutterBackground.initialize(androidConfig: androidConfig);
  //   return FlutterBackground.enableBackgroundExecution();
  // }

  // WidgetsFlutterBinding.ensureInitialized();

  // startForegroundService();
  runApp(const MyApp());
}

const localIp = '192.168.1.103';
const appTitle = 'billd直播';
const themeColor = Color.fromRGBO(255, 215, 0, 1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.paddingOf(context);
    store.setSafeHeight(padding.top);
    return Scaffold(
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
              currentIndex: _currentIndex,
              onTap: (int index) {
                store.setTabIndex(index);
                setState(() {
                  _currentIndex = index;
                  // if (index == 2) {
                  //   store.setBottomNavVisible(false);
                  // }
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 14,
              unselectedFontSize: 14,
              selectedItemColor: themeColor)),
      body: SafeArea(
          child: IndexedStack(
        index: _currentIndex,
        children: [Home(_currentIndex), Area(), Rank(), User(), Live()],
      )),
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
