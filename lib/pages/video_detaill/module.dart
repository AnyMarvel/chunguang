import 'dart:async';
import 'dart:ui';
//
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:fijkplayer/fijkplayer.dart';
// skin
import 'package:chunguang/fijkplayer_skin/fijkplayer_skin.dart';
//
import 'package:chunguang/components/image_extends.dart';
import 'package:chunguang/components/video_banner.dart';
import 'package:chunguang/components/video_factory.dart';
//
//
import 'package:chunguang/request/api_response.dart';
import 'package:chunguang/request/http_utils.dart';
//
import 'package:chunguang/schema/video_related.dart';
//
import 'package:chunguang/service/video_history.dart';
//
import 'package:chunguang/utils/api.dart';
import 'package:chunguang/utils/toast.dart';
//
import 'package:chunguang/widget/my_loading.dart';
import 'package:chunguang/widget/my_state.dart';
import 'package:wakelock/wakelock.dart';

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool speedBtn = true;
  @override
  bool topBar = true;
  @override
  bool lockBtn = true;
  @override
  bool bottomPro = true;
  @override
  bool stateAuto = true;
}

VideoRelated fromJson(dynamic response) => VideoRelated.fromJson(response);

class VideoDetaill extends StatefulWidget {
  const VideoDetaill({Key? key}) : super(key: key);

  @override
  _VideoDetaillState createState() => _VideoDetaillState();
}

class _VideoDetaillState extends State<VideoDetaill> {
  //
  bool isInitAnimition = false;
  //
  String? curPlayUrl = Get.parameters["playUrl"];
  String? videoId = Get.parameters["id"];
  String? title = Get.parameters["title"];
  String? typeName = Get.parameters["typeName"];
  String? desText = Get.parameters["desText"];
  String? subTime = Get.parameters["subTime"];
  String? avatarUrl = Get.parameters["avatarUrl"];
  String? authorDes = Get.parameters["authorDes"];
  String? authorName = Get.parameters["authorName"];
  String? videoPoster = Get.parameters["videoPoster"];
  bool isNotAuthor = Get.parameters["avatarUrl"] == null ? true : false;
  //
  final double playerBoxWidth = 260;

  // 全局控制器
  HistoryService historyService = Get.put(HistoryService());

  final FijkPlayer player = FijkPlayer();
  ShowConfigAbs vSkinCfg = PlayerShowConfig();

  Future<void> initEvent() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // 加入历史记录
    historyService.add(
      id: videoId ?? "",
      playUrl: curPlayUrl ?? "",
      title: title ?? "",
      typeName: typeName ?? "",
      desText: desText ?? "",
      subTime: subTime ?? "",
      avatarUrl: avatarUrl ?? "",
      authorDes: authorDes ?? "",
      authorName: authorName ?? "",
      videoPoster: videoPoster ?? "",
    );
    setState(() {
      // 设置播放源
      player.setDataSource(curPlayUrl ?? "", autoPlay: true);
      isInitAnimition = true;
      Wakelock.enable();
    });
    // if (Platform.isAndroid) {
    //   //设置Android头部的导航栏透明
    //   SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    //     statusBarColor: Colors.black, //全局设置透明
    //     statusBarIconBrightness: Brightness.light,
    //     //light:黑色图标 dark：白色图标
    //     //在此处设置statusBarIconBrightness为全局设置
    //   );
    //   SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    // }
  }

  @override
  void initState() {
    super.initState();
    initEvent();
  }

  @override
  void dispose() async {
    super.dispose();
    Wakelock.disable();
    await player.stop();
    player.release();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isInitAnimition = false;
        });
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: MediaQueryData.fromWindow(window).padding.top,
              color: Colors.black,
            ),
            Container(
              height: playerBoxWidth,
              color: Colors.black,
              child: !isInitAnimition
                  ? Container(
                      height: playerBoxWidth,
                      color: Colors.black,
                    )
                  : FijkView(
                      height: playerBoxWidth,
                      color: Colors.black,
                      fit: FijkFit.cover,
                      player: player,
                      panelBuilder: (
                        FijkPlayer player,
                        FijkData data,
                        BuildContext context,
                        Size viewSize,
                        Rect texturePos,
                      ) {
                        /// 使用自定义的布局
                        return CustomFijkPanel(
                          player: player,
                          viewSize: viewSize,
                          texturePos: texturePos,
                          pageContent: context,
                          playerTitle: title ?? "暂无",
                          showConfig: vSkinCfg,
                          curPlayUrl: curPlayUrl ?? "",
                        );
                      },
                    ),
            ),
            VideoInfo(
              id: videoId ?? "",
              title: title ?? "暂无",
              typeName: typeName ?? "暂无",
              desText: desText ?? "暂无",
              subTime: subTime ?? "暂无",
              avatarUrl: avatarUrl ?? "",
              authorDes: authorDes ?? "暂无",
              authorName: authorName ?? "暂无",
              isNotAuthor: isNotAuthor,
              // player: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class VideoInfo extends StatefulWidget {
  final String id;
  final String title;
  final String typeName;
  final String desText;
  final String subTime;
  final String avatarUrl;
  final String authorName;
  final String authorDes;
  final bool isNotAuthor;
  const VideoInfo({
    Key? key,
    required this.id,
    required this.title,
    required this.typeName,
    required this.desText,
    required this.subTime,
    required this.avatarUrl,
    required this.authorName,
    required this.authorDes,
    required this.isNotAuthor,
  }) : super(key: key);

  @override
  VideoInfoState createState() => VideoInfoState();
}

class VideoInfoState extends State<VideoInfo> {
  String get id => widget.id;
  bool get isNotAuthor => widget.isNotAuthor;
  // BetterVideoPlayerController get player => widget.player;
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  String nextPageUrl = Api.getRelatedData;
  final List<VideoRelatedItemList?> _itemList = [];

  Future<ApiResponse<VideoRelated>> getVideoRelatedData() async {
    try {
      dynamic response = await HttpUtils.get('$nextPageUrl?id=$id');
      // print(response);
      VideoRelated data = await compute(fromJson, response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      // print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _pullData() async {
    ApiResponse<VideoRelated> relatedResponse = await getVideoRelatedData();
    if (!mounted) {
      return;
    }
    if (relatedResponse.status == Status.completed) {
      setState(() {
        stateCode = 1;
        _itemList.addAll(relatedResponse.data!.itemList ?? []);
        // print(relatedResponse.data!.itemList);
      });
    } else if (relatedResponse.status == Status.error) {
      setState(() {
        stateCode = 2;
      });
      String errMsg = relatedResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置video_detaill， url: $nextPageUrl?id=$id");
    }
  }

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyView;
    if (stateCode == 0) {
      bodyView = Container(
        alignment: Alignment.center,
        child: const MyLoading(message: "加载中"),
      );
    } else if (stateCode == 1) {
      bodyView = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  // 标题
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // 类型
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '类型： ${widget.typeName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // 介绍
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      widget.desText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            !isNotAuthor
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: VideoBanner(
                      avatarUrl: widget.avatarUrl,
                      rowTitle: widget.authorName,
                      rowDes: widget.authorDes,
                      slotChild: Container(),
                    ),
                  )
                : Container(),
            Divider(height: isNotAuthor ? 0 : 1),
            Column(
              children: _itemList.map((e) {
                return VideoFactory(
                  id: e!.data!.id!.toString(),
                  playUrl: e.data!.playUrl ?? "",
                  title: e.data!.title ?? "暂无",
                  typeName: e.data!.category ?? "暂无",
                  desText: e.data!.description ?? "暂无",
                  subTime: e.data!.releaseTime != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                              e.data!.releaseTime!)
                          .toString()
                          .substring(0, 19)
                      : "暂无",
                  avatarUrl: e.data!.author != null
                      ? (e.data!.author!.icon ?? "")
                      : "",
                  authorDes: e.data!.author != null
                      ? (e.data!.author!.description ?? "暂无")
                      : "暂无",
                  authorName: e.data!.author != null
                      ? (e.data!.author!.name ?? "暂无")
                      : "暂无",
                  videoPoster: e.data!.cover!.feed ?? "",
                  isPopCurRoute: true,
                  routerPopEnter: () async {
                    // await player.pause();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: ImageExends(
                              imgUrl: e.data!.cover!.feed ?? "",
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.data!.title ?? "暂无",
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    e.data!.description ?? "暂无",
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      );
    } else if (stateCode == 2) {
      bodyView = Container(
        alignment: Alignment.center,
        child: MyState(
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            await _pullData();
          },
          icon: const Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "数据加载失败",
          btnText: "点击重试",
        ),
      );
    } else {
      bodyView = Container();
    }
    return Expanded(
      child: bodyView,
    );
  }
}
