import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'custom_widgets/about_tile.dart';
import 'utility/constants.dart';

class AboutApp extends StatefulWidget{
  @override
  _AboutAppState createState() {
    return _AboutAppState();
  }
}

class _AboutAppState extends State<AboutApp>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
              fontFamily: kQuicksand,
              fontWeight: FontWeight.bold,
              color: kTextColorWhite,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  color: kCardColor,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment:CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
//                          Icon(
//                            Icons.school,
//                            size: 50.0,
//                            color: Theme.of(context).accentColor,
//                          ),
//                          SizedBox(width: 20.0,),
                            Text(
                              "Frequency",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 50.0,
                                fontFamily: kQuicksand,
                                fontWeight: FontWeight.bold,
                                color: kTextColorWhite
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0,),
                        Text(
                          'Appplication',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: kTextColorWhite,
                          ),
                        ),
                        AboutTile(
                          icon: AntDesign.infocirlceo,
                          header: 'Version',
                          text: '0.8.0 - beta',
                        ),
                        AboutTile(
                          icon: AntDesign.unknowfile1,
                          header: 'License',
                          text: 'Open',
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: kCardColor,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Author',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: kTextColorWhite
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: (){
                            //TODO;
                          },
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'Prateek Kumar Oraon',
                            text: '@prateekKrOraon',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: kCardColor,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Place',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: kTextColorWhite
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        AboutTile(
                          icon: MaterialCommunityIcons.city_variant_outline,
                          header: 'National Institute of Technology Sikkim',
                          text: 'India',
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: SimpleLineIcons.location_pin,
                            header: 'Ravangla, South Sikkim',
                            text: 'Sikkim - 737139',
                          ),
                          onTap: (){
                            //TODO: link to github
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: kCardColor,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Third Party Plugins',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: kTextColorWhite
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'Flute Music Player',
                            text: '@iampawan',
                          ),
                          onTap: (){
                            //TODO: link to github
                          },
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'Flutter Vector Icons',
                            text: '@pd4d10',
                          ),
                          onTap: (){
                            //TODO
                          },
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'ScopedModel',
                            text: 'Unknown',
                          ),
                          onTap: (){
                            //TODO
                          },
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'Sqflite',
                            text: '@tekartik',
                          ),
                          onTap: (){
                            //TODO
                          },
                        ),
                        GestureDetector(
                          child: AboutTile(
                            icon: MaterialCommunityIcons.github_circle,
                            header: 'Flutter Media Notification',
                            text: '@aliyazdi75',
                          ),
                          onTap: (){
                            //TODO
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}