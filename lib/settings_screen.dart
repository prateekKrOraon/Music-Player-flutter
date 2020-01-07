import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:frequency_music_player/utility/database_helper.dart';

class SettingsScreen extends StatefulWidget{
  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen>{

  bool switchValue = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double fullHeight = MediaQuery.of(context).size.height;
    double fullWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            SimpleLineIcons.arrow_left,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          'App Settings',
          style: TextStyle(
            fontFamily: kQuicksand,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Dark Theme',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Switch(
                      activeColor: Colors.blue,
                      inactiveTrackColor: Colors.grey,
                      inactiveThumbColor: Colors.grey[600],
                      onChanged: (value) {
                        setState(() {
                          switchValue = value;
                        });
                      },
                      value: switchValue,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  //refreshMusicList();
                  setState(() {
                    isLoading = true;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context ){
                      Future.delayed(Duration(milliseconds: 1000)).then((value){
                        refreshMusicList();
                      });
                      return AlertDialog(
                        title: Text(
                          'Refreshing list',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20,
                          ),
                        ),
                        content: isLoading? Container(
                          child: CircularProgressIndicator(),
                        ):Text(
                          'List Updated. Need to restart the app.',
                          style: TextStyle(
                            fontFamily: kQuicksand,
                            fontSize: 20,
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                fontFamily: kQuicksand,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  );
                },
                child: Container(
                  width: fullWidth,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Refresh Music List',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void refreshMusicList() async {
    List<Song> songs;
    DatabaseHelper database = DatabaseHelper();
    await database.initDataBase();

    try{
      songs = await MusicFinder.allSongs();
    }catch(e){
      print('could not load songs');
    }

    for(Song song in songs){
      database.updateList(song);
    }

    setState(() {
      isLoading = false;
    });

  }
}