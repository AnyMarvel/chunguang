import 'package:chunguang/api/DouBanApi.dart';
import 'package:chunguang/request/http_request.dart';
import 'package:dio/dio.dart';
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


import 'dart:convert';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // debugPaintSizeEnabled = true;
  await initStore();
  runApp(const MyApp());
  print("final Access lijuntao");
  getDoubanData();
}
Future<void> getDoubanData() async{
  try{
    print("xxxxxx");
    Map<String,String> header={"Referer":"https://m.douban.com/tv/"};
    Options options=Options(headers: header);
    String response = await HttpUtils.get(DouBanApi.doubanTest,options: options);
    print("==================");

    print(response.substring(response.indexOf("(")+1,response.lastIndexOf(")")-1));

  }on Error catch (e){
    print("xxxxxx");
  }
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
