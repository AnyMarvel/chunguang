import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:share_extend/share_extend.dart';
import 'package:url_launcher/url_launcher.dart';
//
import 'package:chunguang/router/index.dart';
import 'package:chunguang/utils/config.dart';

class AppBarTabUser extends StatefulWidget {
  const AppBarTabUser({Key? key}) : super(key: key);

  @override
  _AppBarTabUserState createState() => _AppBarTabUserState();
}

class _AppBarTabUserState extends State<AppBarTabUser>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> items = [
    {
      "type": "data",
      "name": "项目仓库",
      "icon": Icons.public,
      "icoColor": Colors.red[800],
      "cb": () async {
        if (await canLaunch(myGithub)) {
          await launch(myGithub);
        }
      },
    },
    {
      "type": "data",
      "name": "历史记录",
      "icon": Icons.history,
      "icoColor": Colors.amber[800],
      "cb": () {
        PageRoutes.addRouter(routeName: PageName.videoHistory);
      },
    },
    {
      "type": "data",
      "name": "分享APP",
      "icon": Icons.share,
      "icoColor": Colors.green[800],
      "cb": () {
        ShareExtend.share(appName, "text");
      },
    },
    {
      "type": "data",
      "name": "免责申明",
      "icon": Icons.feedback,
      "icoColor": Colors.blue[800],
      "cb": () {
        PageRoutes.addRouter(routeName: PageName.userDeclare);
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 8.0,
        title: Container(
          alignment: Alignment.center,
          child: const Text("我的"),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.black12,
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Image.asset("images/user-logo.jpg"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "开不开眼",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Column(
              children: items.map((e) {
                return MenuRow(
                  cb: e["cb"]!,
                  icoColor: e["icoColor"]!,
                  name: e["name"]!,
                  icon: e["icon"]!,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MenuRow extends StatelessWidget {
  final Function cb;
  final String name;
  final Color icoColor;
  final IconData icon;
  const MenuRow({
    Key? key,
    required this.cb,
    required this.icon,
    required this.name,
    required this.icoColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          cb();
        },
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: icoColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
