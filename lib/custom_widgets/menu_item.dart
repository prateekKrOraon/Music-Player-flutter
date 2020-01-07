import 'package:flutter/material.dart';
import 'package:frequency_music_player/utility/constants.dart';

class MenuItem extends StatelessWidget{

  final String text;
  final IconData iconData;
  final Function onTap;

  MenuItem({this.text,this.iconData,this.onTap});

  final Color menuIconColor = ThemeData.light().accentColor;
  final Color menuTextColor = Colors.white;
  final EdgeInsets menuItemPadding = EdgeInsets.symmetric(horizontal: 5);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: menuItemPadding,
      trailing: Icon(
        iconData,
        color: menuIconColor,
      ),
      title: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: menuTextColor,
          fontSize: 20,
          fontFamily: kQuicksand,
          fontWeight: FontWeight.bold
        ),
      ),
      onTap: onTap,
    );
  }

}