import 'package:billd_live_flutter/api/user_api.dart';
import 'package:billd_live_flutter/components/Loading/index.dart';
import 'package:billd_live_flutter/const.dart';
import 'package:billd_live_flutter/stores/app.dart';
import 'package:billd_live_flutter/views/live/live.dart';
import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:get/get.dart';
import 'package:billd_live_flutter/utils/index.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<StatefulWidget> createState() => UserState();
}

class UserState extends State<User> {
  // int? id;
  // String? password;
  int? id = 101;
  String? password = '123456a';
  bool isLogin = false;

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 检测页面是否在前台
    billdPrint('检测页面是否在前台user', state);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Controller store = Get.put(Controller());

    return Column(children: [
      isLogin == true
          ? Container(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                store.userInfo['avatar'] == null ||
                        store.userInfo['avatar'] == ''
                    ? Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                      )
                    : CircleAvatar(
                        backgroundImage:
                            billdNetworkImage(store.userInfo['avatar']),
                      ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: Column(
                    children: [
                      Obx(() => Text('${store.userInfo['username']}')),
                      Obx(() => Text(
                          '${store.userInfo['roles'].map((v) => v['role_name'])}'))
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: BrnBigGhostButton(
                    title: '直播中心',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Live(),
                        ),
                      );
                    },
                  ),
                ),
                BrnBigGhostButton(
                  title: '退出登录',
                  bgColor: const Color.fromRGBO(244, 67, 54, 0.2),
                  titleColor: const Color.fromRGBO(244, 67, 54, 1),
                  onTap: () {
                    BrnDialogManager.showConfirmDialog(context,
                        barrierDismissible: false,
                        title: '提示',
                        message: '确定退出登录？',
                        cancel: '取消',
                        confirm: '确定',
                        onCancel: () => {Navigator.pop(context)},
                        onConfirm: () {
                          setState(() {
                            BrnToast.show('退出登录成功', context,
                                duration: const Duration(seconds: 1));
                            isLogin = false;
                            store.setToken('');
                            store.setUserInfo({});
                            Navigator.pop(context);
                          });
                        });
                  },
                )
              ]),
            )
          : Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      '欢迎登录',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  BrnTextInputFormItem(
                    controller: TextEditingController()..text = '${id ?? ''}',
                    title: "账号",
                    hint: "请输入账号",
                    inputType: BrnInputType.number,
                    onTip: () {},
                    onAddTap: () {},
                    onRemoveTap: () {},
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue != '') {
                          id = int.parse(newValue);
                        }
                      });
                    },
                  ),
                  BrnTextInputFormItem(
                    controller: TextEditingController()..text = password ?? '',
                    title: "密码",
                    hint: "请输入密码",
                    inputType: BrnInputType.pwd,
                    obscureText: true,
                    onTip: () {},
                    onAddTap: () {},
                    onRemoveTap: () {},
                    onChanged: (newValue) {
                      setState(() {
                        password = newValue;
                      });
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: BrnBigGhostButton(
                      title: '登录',
                      onTap: () async {
                        if (id == null || password == null) {
                          BrnToast.show('请输入完整', context,
                              duration: const Duration(seconds: 1));
                          return;
                        }
                        if (password!.length < 6 || password!.length > 10) {
                          BrnToast.show('密码长度要求6-10位', context,
                              duration: const Duration(seconds: 1));
                          return;
                        }
                        var res;
                        try {
                          BilldLoading.showLoading(context);
                          res = await UserApi.idLogin(
                              id: id!, password: password!);
                          if (res['code'] != 200) {
                            if (context.mounted) {
                              BrnToast.show(res?['message'], context);
                            }
                            return;
                          }
                          store.setToken(res['data']);
                          var res1 = await UserApi.getUserInfo();
                          if (res1['code'] == 200) {
                            if (context.mounted) {
                              BrnToast.show('登录成功', context,
                                  duration: const Duration(seconds: 1));
                            }
                            store.setUserInfo(res1['data']);
                            setState(() {
                              isLogin = true;
                            });
                          } else {
                            if (context.mounted) {
                              var errmsg = res?['message'];
                              errmsg ??= networkErrorMsg;
                              BrnToast.show(errmsg, context);
                            }
                          }
                        } catch (e) {
                          billdPrint(e);
                          if (context.mounted) {
                            var errmsg = res?['message'];
                            errmsg ??= networkErrorMsg;
                            BrnToast.show(errmsg, context);
                          }
                        } finally {
                          BilldLoading.stop();
                        }
                      },
                    ),
                  )
                ],
              ))
    ]);
  }
}
