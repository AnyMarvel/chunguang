import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
//
import 'package:chunguang/components/image_extends.dart';
import 'package:chunguang/components/video_banner.dart';
import 'package:chunguang/components/video_factory.dart';
//
import 'package:chunguang/request/api_response.dart';
import 'package:chunguang/request/http_utils.dart';
//
import 'package:chunguang/schema/reel_info.dart';
//
import 'package:chunguang/utils/api.dart';
import 'package:chunguang/utils/toast.dart';
//
import 'package:chunguang/widget/my_loading.dart';
import 'package:chunguang/widget/my_state.dart';

ReelInfo fromJson(dynamic response) => ReelInfo.fromJson(response);

class ReelDetaill extends StatefulWidget {
  const ReelDetaill({Key? key}) : super(key: key);

  @override
  _ReelDetaillState createState() => _ReelDetaillState();
}

class _ReelDetaillState extends State<ReelDetaill> {
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  ReelInfo? reelInfo;
  String pageTitle = Get.parameters["title"] ?? "专题";
  String initPageUrl = Api.topicsDetailUrl;

  Future<ApiResponse<ReelInfo>> getReelInfoData() async {
    try {
      String paramId = Get.parameters["id"]!;
      dynamic response = await HttpUtils.get(initPageUrl + paramId);
      // print(response);
      ReelInfo data = await compute(fromJson, response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      // print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _pullData() async {
    // 延时下再加载，防止和路由动画重叠，卡顿
    await Future.delayed(const Duration(milliseconds: 400));
    ApiResponse<ReelInfo> reelInfoResponse = await getReelInfoData();
    if (!mounted) {
      return;
    }
    if (reelInfoResponse.status == Status.completed) {
      setState(() {
        stateCode = 1;
        reelInfo = reelInfoResponse.data;
      });
    } else if (reelInfoResponse.status == Status.error) {
      setState(() {
        stateCode = 2;
      });
      String errMsg = reelInfoResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置reel_detaill， url: $initPageUrl");
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
      bodyView = const MyLoading(message: "加载中");
    } else if (stateCode == 1) {
      bodyView = SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Header(
              title: reelInfo!.brief!,
              desText: reelInfo!.text,
              bgImg: reelInfo!.headerImage,
            ),
            CollList(
              children: reelInfo!.itemList!,
            ),
          ],
        ),
      );
    } else if (stateCode == 2) {
      bodyView = MyState(
        cb: () async {
          setState(() {
            stateCode = 0;
          });
          // 重新加载
          await _pullData();
        },
        icon: const Icon(
          Icons.new_releases,
          size: 100,
          color: Colors.red,
        ),
        text: "数据加载失败",
        btnText: '点击重试',
      );
    } else {
      bodyView = Container();
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 8.0,
        title: Container(
          alignment: Alignment.center,
          child: Text(pageTitle),
        ),
        actions: [
          Container(),
        ],
      ),
      body: bodyView,
    );
  }
}

class Header extends StatelessWidget {
  final String? bgImg;
  final String? title;
  final String? desText;
  const Header({
    Key? key,
    this.bgImg,
    this.title,
    this.desText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: 220,
              child: ImageExends(
                imgUrl: bgImg ?? "",
              ),
            ),
          ),
          Positioned(
            left: 15,
            right: 15,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 10,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    // title
                    Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          title ?? "暂无",
                          maxLines: 1,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // des
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        desText ?? "暂无",
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CollList extends StatelessWidget {
  final List<ReelInfoItemList?>? children;
  const CollList({Key? key, this.children}) : super(key: key);

  Widget _buildContextWidget() {
    if (children!.isEmpty) {
      return SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.new_releases,
              size: 60,
              color: Colors.red,
            ),
            SizedBox(height: 10),
            Text('暂无专题内容 ╮(╯▽╰)╭'),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Column(
          children: children!.map((e) {
            String videoPoster = e!.data!.content!.data!.cover!.feed ?? "";
            return Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    VideoBanner(
                      avatarUrl: e.data!.content!.data!.author!.icon ?? "",
                      rowTitle: e.data!.content!.data!.author!.name ?? "暂无",
                      slotChild: Container(),
                      rowDes: e.data!.content!.data!.releaseTime != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                                  e.data!.content!.data!.releaseTime!)
                              .toString()
                              .substring(0, 19)
                          : "暂无",
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.data!.content!.data!.title ?? "暂无",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        e.data!.content!.data!.descriptionEditor ?? "暂无",
                        maxLines: 3,
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 210,
                      child: VideoFactory(
                        id: e.id!.toString(),
                        playUrl: e.data!.content!.data!.playUrl ?? "",
                        title: e.data!.content!.data!.title ?? "暂无",
                        typeName: e.data!.content!.data!.category ?? "暂无",
                        desText: e.data!.content!.data!.description ?? "暂无",
                        subTime: e.data!.content!.data!.releaseTime != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                                    e.data!.content!.data!.releaseTime!)
                                .toString()
                                .substring(0, 19)
                            : "暂无",
                        avatarUrl: e.data!.content!.data!.author != null
                            ? (e.data!.content!.data!.author!.icon ?? "")
                            : "",
                        authorDes: e.data!.content!.data!.author != null
                            ? (e.data!.content!.data!.author!.description ??
                                "暂无")
                            : "暂无",
                        authorName: e.data!.content!.data!.author != null
                            ? (e.data!.content!.data!.author!.name ?? "暂无")
                            : "暂无",
                        videoPoster: videoPoster,
                        child: ImageExends(
                          imgUrl: videoPoster,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContextWidget();
  }
}
