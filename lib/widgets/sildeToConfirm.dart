import 'package:flutter/material.dart';
import 'package:prive/size_config.dart';

class ConfirmationSlider extends StatefulWidget {
  /// Height of the slider. Defaults to 70.
  final double height;

  /// Width of the slider. Defaults to 300.
  final double width;

  /// The color of the background of the slider. Defaults to Colors.white.
  final Color backgroundColor;

  /// The color of the background of the slider when it has been slide to the end. By giving a value here, the background color
  /// will gradually change from backgroundColor to backgroundColorEnd when the user slides. Is not used by default.
  final Color backgroundColorEnd;

  /// The color of the moving element of the slider. Defaults to Colors.blueAccent.
  final Color foregroundColor;

  /// The color of the icon on the moving element. Defaults to Colors.white.
  final Color iconColor;

  /// The icon used on the moving element of the slider. Defaults to Icons.chevron_right.
  final IconData icon;

  /// The shadow below the slider. Defaults to BoxShadow(color: Colors.black38, offset: Offset(0, 2),blurRadius: 2,spreadRadius: 0,).
  final BoxShadow shadow;

  /// The text showed below the foreground. Used to specify the functionality to the user. Defaults to "Slide to confirm".
  final String text;

  /// The style of the text. Defaults to TextStyle(color: Colors.black26, fontWeight: FontWeight.bold,).
  final TextStyle textStyle;

  /// The callback when slider is completed. This is the only required field.
  final VoidCallback onConfirmation;

  /// The shape of the moving element of the slider. Defaults to a circular border radius
  final BorderRadius foregroundShape;

  /// The shape of the background of the slider. Defaults to a circular border radius
  final BorderRadius backgroundShape;

  const ConfirmationSlider(
      {Key key,
      @required this.height,
      @required this.width,
      this.backgroundColor = Colors.white,
      this.backgroundColorEnd,
      this.foregroundColor = Colors.blueAccent,
      this.iconColor = Colors.white,
      this.shadow,
      this.icon = Icons.chevron_right,
      this.text = "Slide to confirm",
      this.textStyle,
      @required this.onConfirmation,
      this.foregroundShape,
      this.backgroundShape});
  // : assert(height >= getHeight(25) && width >= getWidth(250));

  @override
  State<StatefulWidget> createState() {
    return ConfirmationSliderState();
  }
}

class ConfirmationSliderState extends State<ConfirmationSlider> {
  double _position = 0;
  int _duration = 0;

  double getPosition() {
    if (_position < 0) {
      return 0;
    } else if (_position > widget.width - widget.height) {
      return widget.width - widget.height;
    } else {
      return _position;
    }
  }

  void updatePosition(details) {
    if (details is DragEndDetails) {
      setState(() {
        _duration = 600;
        _position = 0;
      });
    } else if (details is DragUpdateDetails) {
      setState(() {
        _duration = 0;
        _position = details.localPosition.dx - (widget.height / 2);
      });
    }
  }

  void sliderReleased(details) {
    if (_position > widget.width - widget.height) {
      widget.onConfirmation();
    }
    updatePosition(details);
  }

  Color calculateBackground() {
    double percent;

    // calculates the percentage of the position of the slider
    if (_position > widget.width - widget.height) {
      percent = 1.0;
    } else if (_position / (widget.width - widget.height) > 0) {
      percent = _position / (widget.width - widget.height);
    } else {
      percent = 0.0;
    }

    int red = widget.backgroundColorEnd.red;
    int green = widget.backgroundColorEnd.green;
    int blue = widget.backgroundColorEnd.blue;

    return Color.alphaBlend(
        Color.fromRGBO(red, green, blue, percent), widget.backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    BoxShadow shadow;
    if (widget.shadow == null) {
      shadow = BoxShadow(
        color: Colors.black38,
        offset: Offset(0, 2),
        blurRadius: 2,
        spreadRadius: 0,
      );
    } else {
      shadow = widget.shadow;
    }

    TextStyle style;
    if (widget.textStyle == null) {
      style = TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.bold,
      );
    } else {
      style = widget.textStyle;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: _duration),
      curve: Curves.ease,
      height: widget.height,
      width: widget.width,
      // padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: widget.backgroundShape ??
            BorderRadius.all(Radius.circular((widget.height))),
        color: widget.backgroundColorEnd != null
            ? this.calculateBackground()
            : widget.backgroundColor,
        boxShadow: <BoxShadow>[shadow],
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: getWidth(50)),
            child: Center(
              child: Text(
                widget.text,
                style: style,
              ),
            ),
          ),
          Positioned(
            left: widget.height / 2,
            child: AnimatedContainer(
              height: widget.height - getHeight(10),
              width: getPosition(),
              duration: Duration(milliseconds: _duration),
              curve: Curves.ease,
              decoration: BoxDecoration(
                borderRadius: widget.backgroundShape ??
                    BorderRadius.all(Radius.circular(widget.height)),
                color: widget.backgroundColorEnd != null
                    ? this.calculateBackground()
                    : widget.backgroundColor,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: _duration),
            curve: Curves.bounceOut,
            left: getPosition(),
            top: 0,
            child: GestureDetector(
              onPanUpdate: (details) => updatePosition(details),
              onPanEnd: (details) => sliderReleased(details),
              child: Container(
                height: widget.height,
                width: widget.height,
                decoration: BoxDecoration(
                  borderRadius: widget.foregroundShape ??
                      BorderRadius.all(Radius.circular(widget.height / 2)),
                  color: widget.foregroundColor,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: widget.height * 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
