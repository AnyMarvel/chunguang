import 'package:flutter/material.dart';
import 'package:get/get.dart';
// components
import 'package:chunguang/components/image_extends.dart';
import 'package:chunguang/components/video_factory.dart';
// utils
import 'package:chunguang/utils/toast.dart';
// widget
import 'package:chunguang/widget/my_loading.dart';
import 'package:chunguang/widget/my_button.dart';
import 'package:chunguang/widget/my_state.dart';
// glabel controller
import 'package:chunguang/service/video_history.dart';
// page controller
import 'package:chunguang/pages/video-history/controller.dart';

class VideoHistory extends GetView<VideoHistoryStore> {
  const VideoHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistoryService historyService = Get.put(HistoryService());
    //
    AppBar _buildPublicAppBar() {
      return AppBar(
        elevation: 8.0,
        title: const Text("历史记录"),
      );
    }

    // 读取全局控制器中的历史记录
    List<Widget> _buildStoreVideoList() {
      return historyService.hisList.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12),
                top: BorderSide(color: Colors.black12),
                right: BorderSide(color: Colors.black12),
              ),
            ),
            child: VideoFactory(
              id: e["id"] ?? "",
              playUrl: e["playUrl"] ?? "",
              authorDes: e["authorDes"] ?? "暂无",
              authorName: e["authorName"] ?? "暂无",
              avatarUrl: e["avatarUrl"] ?? "",
              subTime: e["subTime"] ?? "暂无",
              desText: e["desText"] ?? "暂无",
              title: e["title"] ?? "暂无",
              typeName: e["typeName"] ?? "暂无",
              videoPoster: e["videoPoster"] ?? "",
              isHero: false,
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: ImageExends(
                      imgUrl: e["videoPoster"] ?? "",
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
                            e["title"],
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e["desText"],
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
      }).toList();
    }

    return controller.obx(
      (state) => Scaffold(
        appBar: AppBar(
          elevation: 8.0,
          title: const Text("历史记录"),
          actions: [
            MyIconButton(
              icon: const Icon(Icons.restore_from_trash),
              cb: () {
                historyService.removeKey("history").then((res) {
                  publicToast("删除成功");
                  historyService.hisList = [].obs;
                }).catchError((err) {
                  // print(err);
                  publicToast("删除失败");
                });
              },
            ),
          ],
        ),
        body: historyService.hisList.isNotEmpty
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: Column(
                    children: _buildStoreVideoList(),
                  ),
                ),
              )
            : MyState(
                cb: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.new_releases,
                  size: 100,
                  color: Colors.red,
                ),
                text: "暂无内容 ╮(╯▽╰)╭",
                btnText: '点击退出',
              ),
      ),
      onLoading: Scaffold(
        appBar: _buildPublicAppBar(),
        body: const MyLoading(message: "正在加载"),
      ),
      onEmpty: Scaffold(
        appBar: _buildPublicAppBar(),
        body: MyState(
          cb: () async {
            Get.back();
          },
          icon: const Icon(
            Icons.new_releases,
            size: 100,
            color: Colors.red,
          ),
          text: "暂无数据 ╮(╯▽╰)╭",
          btnText: '点击退出',
        ),
      ),
    );
  }
}
