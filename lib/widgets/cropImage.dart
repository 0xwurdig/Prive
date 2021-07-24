import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:get/get.dart';
import 'package:prive/app_theme.dart';
import 'package:prive/size_config.dart';

class CropImage extends StatefulWidget {
  CropImage({this.child, this.image, this.function});
  final Widget child;
  final File image;
  final function;
  @override
  _CropImageState createState() => _CropImageState();
}

double ballDiameter = getText(10);

class _CropImageState extends State<CropImage> {
  double height = getHeight(100);
  double width = getWidth(200);
  bool isCorner = false;
  double ratio;
  double top = 0;
  double left = 0;
  double imageH;
  double imageW;
  @override
  void initState() {
    imageHW(widget.image);
    super.initState();
  }

  imageHW(File image) async {
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    double ratior =
        (decodedImage.height.toDouble() / decodedImage.width.toDouble());
    setState(() {
      imageH = decodedImage.height.toDouble();
      imageW = decodedImage.width.toDouble();
      ratio = ratior;
      height = ratio * MediaQuery.of(context).size.width;
      width = MediaQuery.of(context).size.width;
      // top = (MediaQuery.of(context).size.height - height) / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: getHeight(10),
          ),
          ratio != null
              ? Container(
                  height: ratio * MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: FileImage(widget.image))),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: top,
                        left: left,
                        child: CenterManipulate(
                          onDrag: (dx, dy) {
                            setState(() {
                              isCorner = false;
                              top = top + dy;
                              left = left + dx;
                            });
                          },
                          handlerWidget: HandlerWidget.VERTICAL,
                          child: Container(
                            height: height,
                            width: width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: getWidth(2),
                                color: Colors.white70,
                              ),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            // need tp check if draggable is done from corner or sides
                            child: Center(
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                      // top left
                      Positioned(
                        top: top - ballDiameter / 2,
                        left: left - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width - dx;
                            var newHeight = height - dy;
                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                              height = newHeight > 0 ? newHeight : 0;
                              top = top + dy;
                              left = left + dx;
                            });
                          },
                          handlerWidget: HandlerWidget.VERTICAL,
                        ),
                      ),
                      // top middle
                      Positioned(
                        top: top - ballDiameter / 2,
                        left: left + width / 2 - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newHeight = height - dy;

                            setState(() {
                              isCorner = false;
                              height = newHeight > 0 ? newHeight : 0;
                              top = top + dy;
                            });
                          },
                          handlerWidget: HandlerWidget.HORIZONTAL,
                        ),
                      ),
                      // top right
                      Positioned(
                        top: top - ballDiameter / 2,
                        left: left + width - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width + dx;
                            var newHeight = height - dy;
                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                              height = newHeight > 0 ? newHeight : 0;
                              top = top + dy;
                            });
                          },
                          handlerWidget: HandlerWidget.VERTICAL,
                        ),
                      ),
                      // center right
                      Positioned(
                        top: top + height / 2 - ballDiameter / 2,
                        left: left + width - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width + dx;
                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                            });
                          },
                          handlerWidget: HandlerWidget.HORIZONTAL,
                        ),
                      ),
                      // bottom right
                      Positioned(
                        top: top + height - ballDiameter / 2,
                        left: left + width - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width + dx;
                            var newHeight = height + dy;
                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                              height = newHeight > 0 ? newHeight : 0;
                            });
                          },
                          handlerWidget: HandlerWidget.VERTICAL,
                        ),
                      ),
                      // bottom center
                      Positioned(
                        top: top + height - ballDiameter / 2,
                        left: left + width / 2 - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newHeight = height + dy;

                            setState(() {
                              isCorner = false;

                              height = newHeight > 0 ? newHeight : 0;
                            });
                          },
                          handlerWidget: HandlerWidget.HORIZONTAL,
                        ),
                      ),
                      // bottom left
                      Positioned(
                        top: top + height - ballDiameter / 2,
                        left: left - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width - dx;
                            var newHeight = height + dy;
                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                              height = newHeight > 0 ? newHeight : 0;
                              left = left + dx;
                            });
                          },
                          handlerWidget: HandlerWidget.VERTICAL,
                        ),
                      ),
                      //left center
                      Positioned(
                        top: top + height / 2 - ballDiameter / 2,
                        left: left - ballDiameter / 2,
                        child: ManipulatingBall(
                          onDrag: (dx, dy) {
                            var newWidth = width - dx;

                            setState(() {
                              isCorner = false;
                              width = newWidth > 0 ? newWidth : 0;
                              left = left + dx;
                            });
                          },
                          handlerWidget: HandlerWidget.HORIZONTAL,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      width: getWidth(100),
                      padding: EdgeInsets.only(bottom: getHeight(20)),
                      // color: Colors.white,
                      child: Center(
                        child: Text(
                          'CANCEL',
                          style: MyTheme.bodyTextMessage.copyWith(
                              fontSize: getText(16), color: Colors.white),
                        ),
                      ))),
              SizedBox(
                width: getWidth(10),
              ),
              GestureDetector(
                  onTap: () async {
                    await FlutterNativeImage.cropImage(
                            widget.image.path,
                            (left *
                                    (imageW /
                                        MediaQuery.of(context).size.width))
                                .toInt(),
                            (top *
                                    (imageH /
                                        (ratio *
                                            MediaQuery.of(context).size.width)))
                                .toInt(),
                            ((width / MediaQuery.of(context).size.width) *
                                    imageW)
                                .toInt(),
                            ((height /
                                        (ratio *
                                            MediaQuery.of(context)
                                                .size
                                                .width)) *
                                    imageH)
                                .toInt())
                        .then((value) async {
                      widget.function(value);
                      Get.back();
                    });
                  },
                  child: Container(
                      width: getWidth(100),
                      padding: EdgeInsets.only(bottom: getHeight(20)),
                      // color: Colors.white,
                      child: Center(
                        child: Text(
                          'DONE',
                          style: MyTheme.bodyTextMessage.copyWith(
                              fontSize: getText(16), color: Colors.white),
                        ),
                      ))),
            ],
          )
        ],
      ),
    ));
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key key, this.onDrag, this.handlerWidget});

  final Function onDrag;
  final HandlerWidget handlerWidget;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

enum HandlerWidget { HORIZONTAL, VERTICAL }

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: this.widget.handlerWidget == HandlerWidget.VERTICAL
              ? BoxShape.circle
              : BoxShape.rectangle,
        ),
      ),
    );
  }
}

class CenterManipulate extends StatefulWidget {
  CenterManipulate({Key key, this.onDrag, this.handlerWidget, this.child});

  final Function onDrag;
  final Widget child;
  final HandlerWidget handlerWidget;

  @override
  _CenterManipulateState createState() => _CenterManipulateState();
}

class _CenterManipulateState extends State<CenterManipulate> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: _handleDrag,
        onPanUpdate: _handleUpdate,
        child: widget.child);
  }
}
