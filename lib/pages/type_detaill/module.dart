import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//
import 'package:chunguang/components/image_extends.dart';
import 'package:chunguang/components/video_banner.dart';
import 'package:chunguang/components/video_factory.dart';
//
import 'package:chunguang/request/api_response.dart';
import 'package:chunguang/request/http_utils.dart';
//
import 'package:chunguang/schema/type_info.dart';
//
import 'package:chunguang/utils/api.dart';
import 'package:chunguang/utils/config.dart';
import 'package:chunguang/utils/toast.dart';
//
import 'package:chunguang/widget/my_button.dart';
import 'package:chunguang/widget/my_loading.dart';
import 'package:chunguang/widget/my_state.dart';

TypeInfo fromJson(dynamic response) => TypeInfo.fromJson(response);

class TypeDetaill extends StatefulWidget {
  const TypeDetaill({Key? key}) : super(key: key);

  @override
  _TypeDetaillState createState() => _TypeDetaillState();
}

class _TypeDetaillState extends State<TypeDetaill> {
  bool? isInit;
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  final List<TypeInfoItemList?> _itemList = [];
  String initPageUrl = Api.getCategoryDetailList;
  String? nextPageUrl = Api.getCategoryDetailList;
  String addQuery = '&udid=$uuid&deviceModel=$device';
  bool isShowFloatBtn = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  String typeName = Get.parameters["typeName"]!;
  String sliverBg = Get.parameters["headerImg"]!;

  Future<ApiResponse<TypeInfo>> getTypeInfoData() async {
    try {
      String reqUrl = isInit == null
          ? '${nextPageUrl!}?id=${Get.parameters["id"]!}$addQuery'
          : '${nextPageUrl!}$addQuery';
      dynamic response = await HttpUtils.get(reqUrl);
      // print(response);
      TypeInfo data = await compute(fromJson, response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      // print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _loading() async {
    // 延时下再加载，防止和路由动画重叠，卡顿
    await Future.delayed(const Duration(milliseconds: 400));
    ApiResponse<TypeInfo> typeInfoResponse = await getTypeInfoData();
    _setRefreshState(typeInfoResponse);
    if (!mounted) {
      return;
    }
    if (typeInfoResponse.status == Status.completed) {
      setState(() {
        isInit = isInit ?? true;
        stateCode = 1;
        nextPageUrl = typeInfoResponse.data!.nextPageUrl;
        _itemList.addAll(typeInfoResponse.data!.itemList!);
      });
    } else if (typeInfoResponse.status == Status.error) {
      setState(() {
        stateCode = isInit == true ? 1 : 2;
      });
      String errMsg = typeInfoResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置type_detaill， url: $nextPageUrl");
    }
  }

  void _setRefreshState(ApiResponse<TypeInfo> res) {
    if (!mounted) return;
    if (res.status == Status.completed && res.data!.nextPageUrl == null) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  void _initScrollEvent() {
    _scrollController.addListener(() {
      if (_scrollController.offset < 1000 && isShowFloatBtn) {
        setState(() {
          isShowFloatBtn = false;
        });
      } else if (_scrollController.offset >= 1000 && isShowFloatBtn == false) {
        setState(() {
          isShowFloatBtn = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loading();
    _initScrollEvent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Widget _buildSliver() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          elevation: 8.0,
          title: Text(typeName),
          pinned: true,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              sliverBg,
              fit: BoxFit.fill,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) {
              bool isNotExistAuthor =
                  _itemList[idx]!.data!.author == null ? true : false;
              String videoPoster = _itemList[idx]!.data!.cover!.feed ?? "";
              String videoCategory = _itemList[idx]!.data!.category ?? "暂无";
              String videoTitle = _itemList[idx]!.data!.title ?? "暂无";
              return Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 210,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: VideoFactory(
                              id: _itemList[idx]!.data!.id!.toString(),
                              playUrl: _itemList[idx]!.data!.playUrl ?? "",
                              title: _itemList[idx]!.data!.title ?? "暂无",
                              typeName: _itemList[idx]!.data!.category ?? "暂无",
                              desText:
                                  _itemList[idx]!.data!.description ?? "暂无",
                              subTime: _itemList[idx]!.data!.releaseTime != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                          _itemList[idx]!.data!.releaseTime!)
                                      .toString()
                                      .substring(0, 19)
                                  : "暂无",
                              avatarUrl: _itemList[idx]!.data!.author != null
                                  ? (_itemList[idx]!.data!.author!.icon ?? "")
                                  : "",
                              authorDes: _itemList[idx]!.data!.author != null
                                  ? (_itemList[idx]!
                                          .data!
                                          .author!
                                          .description ??
                                      "暂无")
                                  : "暂无",
                              authorName: _itemList[idx]!.data!.author != null
                                  ? (_itemList[idx]!.data!.author!.name ?? "暂无")
                                  : "暂无",
                              videoPoster: videoPoster,
                              child: ImageExends(
                                imgUrl: videoPoster,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                ),
                              ),
                              child: Text(
                                videoCategory,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    VideoBanner(
                      avatarUrl: _itemList[idx]!.data!.author!.icon ?? "",
                      rowTitle: videoTitle,
                      isAssets: isNotExistAuthor,
                      rowDes: _itemList[idx]!.data!.author!.name ?? "暂无",
                      slotChild: MyIconButton(
                        icon: const Icon(
                          Icons.share,
                          size: 30,
                          color: Colors.black54,
                        ),
                        cb: () {},
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                  ],
                ),
              );
            },
            childCount: _itemList.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyView;
    if (stateCode == 0) {
      bodyView = const MyLoading(message: "加载中");
    } else if (stateCode == 1) {
      bodyView = SmartRefresher(
        controller: _refreshController,
        enablePullUp: true,
        enablePullDown: false,
        footer: CustomFooter(
          builder: (context, mode) {
            Widget? body;
            if (mode == LoadStatus.idle) {
              body = const Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: 20),
                  Text('内容加载中'),
                ],
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("松手,加载更多！");
            } else if (mode == LoadStatus.noMore) {
              body = const Text("没有更多数据了！");
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        onLoading: _loading,
        child: _buildSliver(),
      );
    } else if (stateCode == 2) {
      bodyView = MyState(
        cb: () async {
          setState(() {
            stateCode = 0;
          });
          await _loading();
        },
        icon: const Icon(
          Icons.new_releases,
          size: 100,
          color: Colors.red,
        ),
        text: "数据加载失败",
        btnText: "点击重试",
      );
    } else {
      bodyView = Container();
    }
    return Scaffold(
      appBar: isInit == null
          ? AppBar(
              elevation: 8.0,
              title: Text(Get.parameters["typeName"] ?? "暂无"),
            )
          : null,
      body: bodyView,
      floatingActionButton: isShowFloatBtn
          ? FloatingActionButton(
              heroTag: 'other',
              tooltip: 'Increment',
              onPressed: () {
                _scrollController.animateTo(
                  .0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
