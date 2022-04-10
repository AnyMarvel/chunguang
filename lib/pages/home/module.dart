import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// appbar view
import 'package:chunguang/pages/home/appbar/home/module.dart';
import 'package:chunguang/pages/home/appbar/explore/module.dart';
import 'package:chunguang/pages/home/appbar/popular/module.dart';
import 'package:chunguang/pages/home/appbar/user/module.dart';
// utils
import 'package:chunguang/utils/toast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? lastPopTime;
  int _curPage = 0;
  final _pageController = PageController(initialPage: 0);

  final List<Widget> tabBarBodyItems = [
    const AppBarTabHome(),
    const AppBarTabExplore(),
    const AppBarTabPopular(),
    const AppBarTabUser(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          elevation: 8.0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _curPage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: "发现"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department), label: "热门"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "我的"),
          ],
          fixedColor: Colors.blue,
          onTap: (int idx) {
            //跳转到指定页面
            _pageController.jumpToPage(idx);
            setState(() => _curPage = idx);
          },
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabBarBodyItems,
        ),
      ),
      onWillPop: () async {
        if (lastPopTime == null ||
            DateTime.now().difference(lastPopTime!) >
                const Duration(seconds: 2)) {
          // 存储当前按下back键的时间
          lastPopTime = DateTime.now();
          // toast
          publicToast("再按一次退出app");
          return false;
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        }
      },
    );
  }
}
