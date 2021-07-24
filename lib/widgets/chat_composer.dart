import 'package:flutter/material.dart';
import 'package:prive/size_config.dart';
import '../app_theme.dart';

Container buildChatComposer() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
    height: getHeight(100),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: getWidth(14)),
            height: getHeight(60),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(getText(30)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message ...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
                Icon(
                  Icons.attach_file,
                  color: Colors.grey[500],
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: getWidth(16),
        ),
        CircleAvatar(
          radius: getText(30),
          backgroundColor: MyTheme.kAccentColor,
          child: Container(
            padding: EdgeInsets.only(left: getWidth(4)),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        )
      ],
    ),
  );
}
