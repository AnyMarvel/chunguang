import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//
import 'package:chunguang/router/index.dart';
//
import 'package:chunguang/service/video_history.dart';
import 'package:chunguang/utils/api.dart';
import 'package:chunguang/utils/storage.dart';
//
import 'package:chunguang/request/http_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true;
  await initStore();
  runApp(const MyApp());
}

Future<void> initStore() async {
  // 初始化本地存储类d
  await SpUtil().init();
  // 初始化request类
  HttpUtils.init(
    baseUrl: Api.baseUrl,
  );
  // 历史记录，全局
  await Get.putAsync(() => HistoryService().init());
  // 全局注入
  // print("全局注入");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: PageRoutes.initRoute,
      getPages: PageRoutes.routes,
    );
  }
}
