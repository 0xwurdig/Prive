import 'package:flutter/material.dart';
import '../app_theme.dart';

Container buildChatComposer() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 100,
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
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
          width: 16,
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: MyTheme.kAccentColor,
          child: Container(
            padding: EdgeInsets.only(left: 4),
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
