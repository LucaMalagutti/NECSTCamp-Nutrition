import 'package:flutter/material.dart';

class SpecialCheckbox extends StatefulWidget {
  final int value;
  final String iconString;

  SpecialCheckbox({Key key, @required this.value, @required this.iconString}) : super(key: key);

  @override
  SpecialCheckboxState createState() => new SpecialCheckboxState();
}

class SpecialCheckboxState extends State<SpecialCheckbox> {
  Color getColor(value) {
    if (value == 1) return Theme.of(context).accentColor;
    else return Colors.blueGrey;
  }

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: getColor(widget.value),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 2.0, // has the effect of softening the shadow
              spreadRadius: 1.5, // has the effect of extending the shadow
              offset: Offset(
                0, // horizontal, move right 10
                2.5, // vertical, move down 10
              ),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ImageIcon(new AssetImage(widget.iconString), color: Colors.white, size: 45),
        ),
      ),
    );
  }
}