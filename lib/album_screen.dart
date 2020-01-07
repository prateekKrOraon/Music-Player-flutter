import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/custom_widgets/blur_icon.dart';
import 'package:frequency_music_player/now_playing_screen.dart';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'modals/song_modal.dart';

class AlbumScreen extends StatefulWidget{

  final MusicFinder audioPlayer;
  final List<Song> songs;

  AlbumScreen(this.songs,this.audioPlayer);

  @override
  AlbumScreenState createState() {
    return AlbumScreenState(songs: songs,audioPlayer: audioPlayer);
  }
}

class AlbumScreenState extends State<AlbumScreen>{

  final MusicFinder audioPlayer;
  final List<Song> songs;

  AlbumScreenState({this.songs,this.audioPlayer});

  Size size;
  ThemeData theme;
  int selectedSong;
  bool isPlaying;

  @override
  void initState() {
    super.initState();
    isPlaying=false;
  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    SongModel current;
    setState(() {
      current = ScopedModel.of<SongModel>(context);
    });

    if(current != null){
      isPlaying = current.isPlayingSong;
      selectedSong = current.getIndex;
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
              ),
              child: Container(
                width: size.width,
                height: size.width,
                decoration: BoxDecoration(
                ),
                child: Image(
                  fit: BoxFit.cover,
                  image: (songs != null && songs[0].albumArt != null)?
                  FileImage(
                    File(songs[0].albumArt),
                  ):
                  AssetImage(kAlbumArtLarge),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: SafeArea(
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
          ),
          Positioned(
            top: size.width - 30,
            right: 30,
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>NowPlaying(
                      audioPlayer: audioPlayer,
                      songs: songs,
                      index: 0,
                      alreadyPlaying: false,
                    )
                  )
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(35),
                  ),
                  color: theme.accentColor,
                ),
                child: Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.width + 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal:10),
              child: Text(
                'Songs',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
          ),
          Positioned(
            top: size.width+65,
            child: Container(
              width: size.width,
              height: size.width - 65,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index){
                  return ListTile(
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: theme.accentColor,
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
                    trailing: (selectedSong != null && isPlaying && index==selectedSong && current.song.id == songs[selectedSong].id)?Icon(
                      MaterialCommunityIcons.play,
                      color: Colors.white,
                    ):SizedBox(),
                    onTap: ()async {
                      selectedSong = index;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: audioPlayer, songs: songs, index: index,alreadyPlaying: (selectedSong != index)? true:false,)));
                      //if(_songs[selectedSong].albumArt == null)
                      //hasAlbumArt = false;
                      setState(() {
                        isPlaying = true;
                      });
                    },

                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}