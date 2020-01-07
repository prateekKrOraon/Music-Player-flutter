import 'package:flutter/material.dart';
import 'package:frequency_music_player/utility/constants.dart';

class AboutTile extends StatelessWidget{
  AboutTile({this.header,this.icon,this.text});
  final IconData icon;
  final String header;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 60.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: Theme.of(context).accentColor,
            size: 25.0,
          ),
          SizedBox(width: 20.0,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                header,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 18.0,
                  color: kTextColorWhite,
                  fontFamily: kQuicksand,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                  color: kTextColorWhite,
                  fontFamily: kQuicksand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}