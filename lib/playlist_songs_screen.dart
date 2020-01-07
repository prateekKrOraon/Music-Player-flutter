import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/now_playing_screen.dart';

import 'custom_widgets/blur_icon.dart';

class PlaylistScreen extends StatefulWidget{

  final List<Song> songs;
  final MusicFinder audioPlayer;
  PlaylistScreen(this.songs,this.audioPlayer);

  @override
  _PlaylistScreenState createState() {
    return _PlaylistScreenState(songs,audioPlayer);
  }
}

class _PlaylistScreenState extends State<PlaylistScreen>{

  final List<Song> songs;
  final MusicFinder audioPlayer;
  _PlaylistScreenState(this.songs,this.audioPlayer);

  int selectedSong;
  bool isPlaying;

  @override
  void initState() {
    super.initState();
    isPlaying = false;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                width: size.width,
                height: size.width,
                child: (songs != null && songs[0].albumArt == null)?
                Icon(
                  MaterialCommunityIcons.music_note,
                  size: 50,
                ):Image(
                  fit: BoxFit.cover,
                  image: FileImage(
                    File(
                      songs[0].albumArt,
                    )
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: BlurIcon(
                          height: 40,
                          width: 40,
                          icon: Icon(
                            SimpleLineIcons.arrow_left,
                            color: Colors.white,
                          ),
                        ),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      ),
                      InkWell(
                        child: BlurIcon(
                          height: 40,
                          width: 40,
                          icon: Icon(
                            SimpleLineIcons.menu,
                            color: Colors.white,
                          ),
                        ),
                        onTap: (){
                          //TODO
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: size.width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black54
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          MaterialCommunityIcons.music_note_plus,
                          color: Colors.white,
                        ),
                        iconSize: 30,
                        onPressed: (){
                          //TODO
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          MaterialCommunityIcons.playlist_play,
                          color: Colors.white,
                        ),
                        iconSize: 30,
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NowPlaying(songs: songs,audioPlayer: audioPlayer,index: 0,alreadyPlaying: false,)
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left:10,top: 10),
            child: Text(
              'Songs',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
          Container(
            width: size.width,
            height: size.height - size.width - 40,
            child: (songs == null)?
            Text(
              'No songs in this playlist',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
              ),
            ):ListView.builder(
              shrinkWrap: true,
              itemCount: songs.length,
              itemBuilder: (BuildContext context, int index){
                return ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).accentColor,
                    radius: 20,
                    child: !(songs[index].albumArt == null)?ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        height: 40,
                        width: 40,
                        fit: BoxFit.fill,
                        image: FileImage(
                          File(songs[index].albumArt),
                        ),
                      ),
                    ):Icon(Icons.music_note,color: Colors.white,),
                  ),
                  title: Text(
                    "${songs[index].title}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    "${songs[index].artist}",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  trailing: (selectedSong!= null && isPlaying && index==selectedSong)?Icon(
                    SimpleLineIcons.volume_2,
                    color: Colors.white,
                  ):SizedBox(),
                  onTap: ()async {
                    selectedSong = await Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: audioPlayer, songs: songs, index: index,)));
                    //if(_songs[selectedSong].albumArt == null)
                    //hasAlbumArt = false;
                    setState(() {
                      isPlaying = true;
                    });
                  },

                );
              },
            ),
          )
        ],
      ),
    );
  }
}