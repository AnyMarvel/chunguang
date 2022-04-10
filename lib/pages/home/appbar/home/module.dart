import 'package:card_swiper/card_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// components
import 'package:chunguang/components/image_extends.dart';
import 'package:chunguang/components/video_banner.dart';
import 'package:chunguang/components/video_factory.dart';
// request
import 'package:chunguang/request/api_response.dart';
import 'package:chunguang/request/http_utils.dart';
// routes
import 'package:chunguang/router/index.dart';
// schema
import 'package:chunguang/schema/feed.dart';
// utils
import 'package:chunguang/utils/api.dart';
import 'package:chunguang/utils/toast.dart';
// widget
import 'package:chunguang/widget/my_button.dart';
import 'package:chunguang/widget/my_loading.dart';
import 'package:chunguang/widget/my_state.dart';

Feed fromJson(dynamic response) => Feed.fromJson(response);

class AppBarTabHome extends StatefulWidget {
  const AppBarTabHome({Key? key}) : super(key: key);

  @override
  _AppBarTabHomeState createState() => _AppBarTabHomeState();
}

class _AppBarTabHomeState extends State<AppBarTabHome>
    with AutomaticKeepAliveClientMixin {
  bool? isInit;
  // 0加载中 1加载成功 2 失败
  int stateCode = 0;
  List<Widget> slivers = [];
  List<FeedIssueListItemList?> _swiperList = [];
  List<FeedIssueListItemList?> _itemList = [];
  String initPageUrl = Api.getFirstHomeData;
  String? nextPageUrl;
  bool isShowFloatBtn = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  final SwiperController _swiperController = SwiperController();

  AppBar _buildPulicAppBar() {
    return AppBar(
      titleSpacing: 0,
      leading: Container(),
      title: Container(
        alignment: Alignment.center,
        child: const Text("日报"),
      ),
      elevation: 8.0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            PageRoutes.addRouter(routeName: PageName.search);
          },
        ),
      ],
    );
  }

  Future<ApiResponse<Feed>> getFeedData(url) async {
    try {
      dynamic response = await HttpUtils.get(url);
      // print(response);
      Feed data = await compute(fromJson, response);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      // print(e);
      return ApiResponse.error(e.error);
    }
  }

  Future<void> _refresh() async {
    _refreshController.refreshCompleted(resetFooterState: true);
    ApiResponse<Feed> swiperResponse = await getFeedData(initPageUrl);
    if (!mounted) {
      return;
    }
    if (swiperResponse.status == Status.completed) {
      setState(() {
        slivers = [];
        nextPageUrl = swiperResponse.data!.nextPageUrl;
        _swiperList = [];
        _swiperList.addAll(swiperResponse.data!.issueList![0]!.itemList!);
        _itemList = [];
        slivers.add(
          BuildHeader(
            list: _swiperList,
            swiperController: _swiperController,
          ),
        );
      });
      // 拉取新的，列表
      await _loading();
    } else if (swiperResponse.status == Status.error) {
      setState(() {
        stateCode = isInit == true ? 1 : 2;
      });
      String errMsg = swiperResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置home bottomBar1 swiper， url: $initPageUrl");
      // print(swiperResponse.exception);
    }
  }

  Future<void> _loading() async {
    ApiResponse<Feed> itemResponse = await getFeedData(nextPageUrl!);
    _setRefreshState(itemResponse);
    if (!mounted) {
      return;
    }
    if (itemResponse.status == Status.completed) {
      setState(() {
        stateCode = 1;
        isInit = isInit ?? true;
        nextPageUrl = itemResponse.data!.nextPageUrl;
        _itemList.addAll(itemResponse.data!.issueList![0]!.itemList!);
        slivers.add(
            _buildLoadingItems(itemResponse.data!.issueList![0]!.itemList));
      });
    } else if (itemResponse.status == Status.error) {
      setState(() {
        stateCode = isInit == true ? 1 : 2;
      });
      String errMsg = itemResponse.exception!.getMessage();
      publicToast(errMsg);
      // print("发生错误，位置home bottomBar1 items， url: $nextPageUrl");
    }
  }

  void _setRefreshState(ApiResponse<Feed> res) {
    if (!mounted) return;
    if (res.status == Status.completed && res.data!.nextPageUrl == null) {
      _refreshController.loadNoData();
    } else {
      _refreshController.loadComplete();
    }
  }

  void _initScrollEvent() {
    _scrollController.addListener(() {
      // 返回顶部按钮
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
  @mustCallSuper
  void initState() {
    super.initState();
    _refresh();
    _initScrollEvent();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Widget _buildLoadingItems(List<FeedIssueListItemList>? itemList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int idx) {
          return BuildItems(target: itemList![idx]);
        },
        childCount: itemList!.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (stateCode == 0) {
      return Scaffold(
        appBar: _buildPulicAppBar(),
        body: const MyLoading(message: "加载中"),
      );
    } else if (stateCode == 1) {
      return Scaffold(
        appBar: _buildPulicAppBar(),
        floatingActionButton: isShowFloatBtn
            ? FloatingActionButton(
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
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
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
          child: CustomScrollView(
            controller: _scrollController,
            slivers: slivers,
          ),
          onRefresh: _refresh,
          onLoading: _loading,
          controller: _refreshController,
        ),
      );
    } else if (stateCode == 2) {
      return Scaffold(
        appBar: _buildPulicAppBar(),
        body: MyState(
          cb: () async {
            setState(() {
              stateCode = 0;
            });
            // 重新加载
            await _refresh();
          },
          icon: const Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "数据加载失败",
          btnText: '点击重试',
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class BuildItems extends StatefulWidget {
  final FeedIssueListItemList? target;
  const BuildItems({Key? key, required this.target}) : super(key: key);

  @override
  State<BuildItems> createState() => _BuildItemsState();
}

class _BuildItemsState extends State<BuildItems> {
  @override
  Widget build(BuildContext context) {
    bool isNotExistAuthor = widget.target!.data!.author == null ? true : false;
    String videoTitle = widget.target!.data!.title ?? "暂无";
    String videoCategory = widget.target!.data!.category ?? "暂无";
    String videoPoster = widget.target!.data!.cover!.feed ?? "";
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                    id: widget.target!.data!.id!.toString(),
                    playUrl: widget.target!.data!.playUrl ?? "",
                    title: widget.target!.data!.title ?? "暂无",
                    typeName: widget.target!.data!.category ?? "暂无",
                    desText: widget.target!.data!.description ?? "暂无",
                    subTime: widget.target!.data!.releaseTime != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                                widget.target!.data!.releaseTime!)
                            .toString()
                            .substring(0, 19)
                        : "暂无",
                    avatarUrl: widget.target!.data!.author != null
                        ? (widget.target!.data!.author!.icon ?? "")
                        : "",
                    authorDes: widget.target!.data!.author != null
                        ? (widget.target!.data!.author!.description ?? "暂无")
                        : "暂无",
                    authorName: widget.target!.data!.author != null
                        ? (widget.target!.data!.author!.name ?? "暂无")
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
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VideoBanner(
            avatarUrl: widget.target!.data!.author!.icon ?? "",
            rowTitle: videoTitle,
            isAssets: isNotExistAuthor,
            rowDes: widget.target!.data!.author!.name ?? "暂无",
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
  }
}

class BuildHeader extends StatefulWidget {
  final List<FeedIssueListItemList?> list;
  final SwiperController swiperController;
  const BuildHeader({
    Key? key,
    required this.list,
    required this.swiperController,
  }) : super(key: key);

  @override
  State<BuildHeader> createState() => _BuildHeaderState();
}

class _BuildHeaderState extends State<BuildHeader> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 210,
          child: Swiper(
            autoplay: true,
            controller: widget.swiperController,
            itemBuilder: (BuildContext context, int idx) {
              String posterUrl = widget.list[idx]!.data!.cover!.feed ?? "";
              String videoTitle = widget.list[idx]!.data!.title ?? "暂无";
              return SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Positioned(
                      child: VideoFactory(
                        id: widget.list[idx]!.data!.id!.toString(),
                        playUrl: widget.list[idx]!.data!.playUrl ?? "",
                        title: widget.list[idx]!.data!.title ?? "暂无",
                        typeName: widget.list[idx]!.data!.category ?? "暂无",
                        desText: widget.list[idx]!.data!.description ?? "暂无",
                        subTime: widget.list[idx]!.data!.releaseTime != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                                    widget.list[idx]!.data!.releaseTime!)
                                .toString()
                                .substring(0, 19)
                            : "暂无",
                        avatarUrl: widget.list[idx]!.data!.author != null
                            ? (widget.list[idx]!.data!.author!.icon ?? "")
                            : "",
                        authorDes: widget.list[idx]!.data!.author != null
                            ? (widget.list[idx]!.data!.author!.description ??
                                "暂无")
                            : "暂无",
                        authorName: widget.list[idx]!.data!.author != null
                            ? (widget.list[idx]!.data!.author!.name ?? "暂无")
                            : "暂无",
                        videoPoster: posterUrl,
                        child: ImageExends(
                          imgUrl: posterUrl,
                        ),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        height: 40,
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                            videoTitle,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      bottom: 0,
                      left: 0,
                      right: 0,
                    ),
                  ],
                ),
              );
            },
            itemCount: widget.list.length,
            pagination: const SwiperPagination(
              margin: EdgeInsets.only(bottom: 45),
            ),
          ),
        ),
      ),
    );
  }
}
