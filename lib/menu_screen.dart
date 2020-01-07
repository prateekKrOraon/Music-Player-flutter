import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/about_app.dart';
import 'package:frequency_music_player/settings_screen.dart';
import 'package:frequency_music_player/sliding_scaffold.dart';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:provider/provider.dart';

import 'custom_widgets/menu_item.dart';

class MenuScreen extends StatefulWidget{
  @override
  _MenuScreenState createState() {
    return _MenuScreenState();
  }
}

class _MenuScreenState extends State<MenuScreen>{

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details){
        if(details.delta.dx < -6){
          Provider.of<MenuController>(context,listen: true).toggle();
        }
      },
      child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          child:Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Frequency',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: kQuicksand,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                MenuItem(
                  text: "Settings",
                  iconData: MaterialCommunityIcons.settings,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen()
                      ),
                    );
                  },
                ),
                MenuItem(
                  text: "About",
                  iconData: MaterialCommunityIcons.information_variant,
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutApp(),
                      ),
                    );
                  },
                ),
                MenuItem(
                  text: "Share",
                  iconData: MaterialCommunityIcons.share_variant,
                  onTap: (){
                    //TODO
                  },
                ),
                MenuItem(
                  text: "Rate this app",
                  iconData: MaterialCommunityIcons.star,
                  onTap: (){
                    //TODO
                  },
                ),
              ],
            ),
          ) ,
        ),
      ),
    );
  }
}