import 'package:flutter/material.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:frequency_music_player/menu_screen.dart';
import 'package:frequency_music_player/sliding_scaffold.dart';
import 'package:provider/provider.dart';



class NowPlaying extends StatefulWidget{

  NowPlaying({this.audioPlayer,this.songs,this.index,this.alreadyPlaying});
  final List<Song> songs;
  final int index;
  final MusicFinder audioPlayer;
  final bool alreadyPlaying;

  @override
  NowPlayingState createState() {
    return NowPlayingState();
  }
}



class NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin{

  MenuController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));

  }





  @override
  void dispose() {
    super.dispose();
  }


  bool isPlaying = false;
  bool hasAlbumArt = true;



  @override
  Widget build(BuildContext context) {


    return ChangeNotifierProvider(
      builder: (context) => _menuController,
      child: SlidingScaffold(
        menu: MenuScreen(),
        content: Layout(
          content: (c){
            return Container();
          },
        ),
        audioPlayer: widget.audioPlayer,
        songs: widget.songs,
        index: widget.index,
        alreadyPlaying: widget.alreadyPlaying,
      ),
    );
  }







}