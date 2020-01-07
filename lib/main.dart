import 'package:flutter/material.dart';
import 'package:frequency_music_player/modals/song_modal.dart';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:frequency_music_player/utility/database_helper.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:frequency_music_player/song_list_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';

typedef void OnError(Exception exception);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<SongModel>(
      model: SongModel(),
      child: MaterialApp(
        title: 'Frequency Music Player',
        theme: ThemeData.dark().copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
          ),
          primaryIconTheme: IconThemeData(
            color: Colors.white,
          ),
          appBarTheme: AppBarTheme(
            color: kBackgroundColor,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
          primaryColor: kPrimaryColor,
          accentColor: kAccentColor,
          scaffoldBackgroundColor: kBackgroundColor,
          cardColor: Colors.grey[800].withOpacity(0.5),
          splashColor: Colors.grey,
          buttonTheme: ButtonThemeData(
            splashColor: Colors.grey,
            highlightColor: Colors.grey,
          ),
        ),
        home: FrequencyHome(),
      ),
    );
  }
}

class FrequencyHome extends StatefulWidget{
  @override
  FrequencyHomeState createState() {
    return FrequencyHomeState();
  }
}

class FrequencyHomeState extends State<FrequencyHome> with SingleTickerProviderStateMixin{

  Duration duration;
  MusicFinder audioPlayer;
  bool isLoadingIntoDatabase;
  bool isFetchingFromDatabase;


  @override
  void initState() {
    super.initState();
    isLoadingIntoDatabase = false;
    isFetchingFromDatabase = false;
    initPlayer();
  }

  initPlayer()async{
    duration = Duration(seconds: 2);
    _loadSongs();
    audioPlayer = MusicFinder();
    audioPlayer.setCompletionHandler((){
      var songsList = ScopedModel.of<SongModel>(context).getSongsList;
      int selectedSong = ScopedModel.of<SongModel>(context).getIndex + 1;
      bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
      print("song changing");
      if(selectedSong != songsList.length -1 ){
        audioPlayer.play(songsList[selectedSong].uri);
        ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
      }
    });
  }

  _loadSongs() async {
    DatabaseHelper database = DatabaseHelper();
    await database.initDataBase();
    if(await database.isDatabaseCreated()){
      setState(() {
        isFetchingFromDatabase = true;
      });
      List<Song> songs = await database.fetchAllSongs();
      List<Song> fav = await database.getFavSongs();
      List<Song> recent = await database.getRecentSongs();
      List<Song> mostPlayed = await database.getMostPlayedSongs();
      recent.forEach((song){
        print(song.title);
      });
      Future.delayed(duration).then((map)=>{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SongsListScreen(audioPlayer,songs,fav,recent,mostPlayed),
          ),
              (route)=>false,
        )
      });

    }else{
      List<Song> songs;
      try{
        songs = await MusicFinder.allSongs();
        if(songs == null || songs.length == 0){
          print("no songs found");
        }else{
          setState(() {
            isLoadingIntoDatabase = true;
          });
          for(Song song in songs){
            database.insertSongsIntoDatabase(song);
            if(!mounted){
              return;
            }
          }
          setState(() {
            isLoadingIntoDatabase = false;
          });
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SongsListScreen(audioPlayer,songs,[],[],[])), (route) => false);
        }
      }catch (e){
        print("failed to fetch songs from storage device");
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: MediaQuery.of(context).size.height/10,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/2,
                child: Center(
                  child: Text(
                    'Frequency',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width/8,
                      letterSpacing: 5,
                      fontFamily: kQuicksand,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Column(
                  children: <Widget>[
                    isLoadingIntoDatabase?CircularProgressIndicator():SizedBox(),
                    isFetchingFromDatabase?CircularProgressIndicator():SizedBox(),
                    SizedBox(height: 20,),
                    isLoadingIntoDatabase?Text(
                      isLoadingIntoDatabase?'Loading songs into database':'',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                        fontFamily: kQuicksand
                      ),
                    ):Text(
                      isFetchingFromDatabase?'Fetching From Database':'',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 20,
                        fontFamily: kQuicksand
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}