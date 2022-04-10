import 'package:flutter/material.dart';
import 'package:chunguang/widget/my_button.dart';

typedef ButtonCb = void Function();

class MyState extends StatelessWidget {
  final ButtonCb? cb;
  final Icon icon;
  final String text;
  final String btnText;
  const MyState({
    Key? key,
    required this.cb,
    required this.icon,
    required this.text,
    required this.btnText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 3),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          MyButton(
            title: btnText,
            cb: cb,
          ),
        ],
      ),
    );
  }
}
