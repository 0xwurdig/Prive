import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prive/app_theme.dart';
import 'package:prive/widgets/cropImage.dart';
import 'package:screenshot/screenshot.dart';

class GetImage extends StatefulWidget {
  const GetImage({this.func});
  final func;
  @override
  _GetImageState createState() => _GetImageState();
}

class _GetImageState extends State<GetImage> {
  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController msg = new TextEditingController();
  File image;
  int imageH;
  int imageW;
  Color color = Colors.red;
  bool doodle = false;
  List<Offset> _points = <Offset>[];
  @override
  void initState() {
    _pickImage();
    super.initState();
  }

  Future<void> _pickImage() async {
    final selected = await ImagePicker().pickImage(
      imageQuality: 100,
      source: ImageSource.camera,
    );
    if (selected != null) {
      ImageProperties prop =
          await FlutterNativeImage.getImageProperties(selected.path);
      // widget.func(File(selected.path));
      setState(() {
        image = (File(selected.path));
        imageH = prop.height;
        imageW = prop.width;
      });
    } else {
      Get.rawSnackbar(
          backgroundColor: MyTheme.kAccentColor,
          messageText: Text("No Image Selected",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black)));
      Get.back();
    }
  }

  setImage(File i) {
    setState(() {
      image = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: image != null
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SafeArea(
                child: Container(
                  color: Colors.black,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (doodle == true)
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _points = [];
                                    });
                                  },
                                  icon: Icon(Icons.clear,
                                      color: Colors.white, size: 30)),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                                onPressed: () {
                                  File asd = new File(image.path + "a");
                                  if (_points != [])
                                    screenshotController
                                        .capture(
                                            pixelRatio: imageH / imageW,
                                            delay: Duration(milliseconds: 10))
                                        .then((capturedImage) async {
                                      asd.writeAsBytesSync(capturedImage);
                                      Get.to(() => CropImage(
                                            image: asd,
                                            child: Container(),
                                            function: setImage,
                                          ));
                                      setState(() {
                                        image = asd;
                                        _points = [];
                                      });
                                    }).catchError((onError) {
                                      Get.rawSnackbar(
                                          backgroundColor: MyTheme.kAccentColor,
                                          messageText: Text(onError,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black)));
                                    });
                                },
                                icon: Icon(Icons.crop,
                                    color: Colors.white, size: 30)),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // if (doodle == true) _points = [];
                                    doodle = !doodle;
                                  });
                                },
                                child: ClipOval(
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: color != null && doodle
                                        ? color
                                        : Colors.transparent,
                                    child: Icon(Icons.edit,
                                        color: Colors.white, size: 30),
                                  ),
                                )),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        doodle || _points != []
                            ? Expanded(
                                child: Center(
                                    child: Screenshot(
                                  controller: screenshotController,
                                  child: imageH != null && imageW != null
                                      ? Container(
                                          clipBehavior: Clip.hardEdge,
                                          height: imageH /
                                              imageW *
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: FileImage(image),
                                          )),
                                          child: GestureDetector(
                                            onPanUpdate:
                                                (DragUpdateDetails details) {
                                              if (doodle)
                                                setState(() {
                                                  RenderBox object = context
                                                      .findRenderObject();
                                                  Offset _localPosition = object
                                                      .globalToLocal(details
                                                          .globalPosition)
                                                      .translate(
                                                          0,
                                                          10 -
                                                              (MediaQuery.of(context)
                                                                          .size
                                                                          .height -
                                                                      (imageH /
                                                                          imageW *
                                                                          MediaQuery.of(context)
                                                                              .size
                                                                              .width)) /
                                                                  2);
                                                  _points =
                                                      new List.from(_points)
                                                        ..add(_localPosition);
                                                });
                                            },
                                            onPanEnd: (DragEndDetails details) {
                                              if (doodle) _points.add(null);
                                            },
                                            child: new CustomPaint(
                                              painter: new Signature(
                                                  points: _points,
                                                  color: color),
                                              size: Size.infinite,
                                            ),
                                            // ),
                                          ),
                                        )
                                      : Container(),
                                )),
                              )
                            : Expanded(child: Image.file(image)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
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
                                          onTap: () {
                                            setState(() {
                                              if (doodle) doodle = false;
                                            });
                                          },
                                          controller: msg,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Type your message ...',
                                            hintStyle: TextStyle(
                                                color: Colors.grey[500]),
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[500],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  if (_points != [])
                                    screenshotController
                                        .capture(
                                            pixelRatio: imageH / imageW,
                                            delay: Duration(milliseconds: 10))
                                        .then((capturedImage) async {
                                      File asd = new File(image.path);
                                      asd.writeAsBytesSync(capturedImage);
                                      setState(() {
                                        image = asd;
                                      });
                                    }).catchError((onError) {
                                      Get.rawSnackbar(
                                          backgroundColor: MyTheme.kAccentColor,
                                          messageText: Text(onError,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black)));
                                    });
                                  widget.func(image, msg.text);
                                  Get.back();
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: MyTheme.kAccentColor,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   width: 30,
                        // ),
                      ]),
                ),
              ),
            )
          : Container(),
      // floatingActionButton: new FloatingActionButton(
      //   child: new Icon(Icons.clear),
      //   onPressed: () => _points.clear(),
      // ),
    );
  }
}

class Signature extends CustomPainter {
  List<Offset> points;
  Color color;
  Signature({this.points, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 1; i < points.length - 1; i++) {
      Paint paint = new Paint()
        ..color = color
        ..strokeCap = StrokeCap.square
        ..strokeWidth = 20;
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawCircle(points[i], 5, paint);
      }
    }
    // for (int i = 0; i < points.length - 1; i++) {
    //   Paint paint = new Paint()
    //     ..color = Colors.blue
    //     ..strokeCap = StrokeCap.round
    //     ..strokeWidth = 10.0;
    //   if (points[i] != null && points[i + 1] != null) {
    //     canvas.drawLine(points[i], points[i], paint);
    //   }
    // }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => oldDelegate.points != points;
}
