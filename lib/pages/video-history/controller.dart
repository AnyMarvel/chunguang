import 'package:get/get.dart';

class VideoHistoryStore extends GetxController with StateMixin {
  // 延迟400，等路由动画完成之后在设置状态
  Future<void> initState() async {
    change("加载中", status: RxStatus.loading());
    await Future.delayed(const Duration(milliseconds: 400));
    change("成功", status: RxStatus.success());
  }

  @override
  void onInit() {
    super.onInit();
    initState();
  }
}
