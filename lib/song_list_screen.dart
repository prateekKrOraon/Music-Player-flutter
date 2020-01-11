import 'dart:io';
import 'dart:ui';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/playlist_songs_screen.dart';
import 'package:frequency_music_player/utility/database_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'album_screen.dart';
import 'modals/song_modal.dart';
import 'now_playing_screen.dart';
import 'utility/constants.dart';

double ourMap(v, start1, stop1, start2, stop2) {
  return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

class SongsListScreen extends StatefulWidget {

  SongsListScreen(this.audioPlayer,this.songs,this.fav,this.recent,this.mostPlayed);
  final MusicFinder audioPlayer;
  final List<Song> songs;
  final List<Song> fav;
  final List<Song> recent;
  final List<Song> mostPlayed;

  @override
  SongsListScreenState createState() => new SongsListScreenState(audioPlayer,songs,fav,recent,mostPlayed);
}

class SongsListScreenState extends State<SongsListScreen> with TickerProviderStateMixin {

  SongsListScreenState(this._audioPlayer,this._songs,this._favSongs,this._recentSongs,this._mostPlayed);
  final MusicFinder _audioPlayer;
  final List<Song> _songs;
  final List<Song> _favSongs;
  final List<Song> _recentSongs;
  final List<Song> _mostPlayed;


  //Tab bar elements


  final _kTabs = <String>[
    'Home',
    'Songs',
    'Albums',
    'Playlist',
  ];

  List<Song> searchResults;
  List<Song> _recent;
  List<Song> _mostPlayedSongs;
  List<Song> _fav;
  final int initPage = 0;
  PageController _pageController;

  BehaviorSubject<int> _currentPageSubject;
  Stream<int> get currentPage => _currentPageSubject.stream;
  Sink<int> get currentPageSink => _currentPageSubject.sink;

  Alignment _dragAlignment;
  AnimationController _controller;
  Animation<Alignment> _animation;

  AnimationController _searchHeightController;
  String _searchText;
  int selectedSong;
  bool isPlaying = false;
  bool hasAlbumArt = true;


  @override
  void initState(){
    super.initState();
    searchResults = [];
    _currentPageSubject = BehaviorSubject<int>.seeded(initPage);
    _pageController = PageController(initialPage: initPage);
    _dragAlignment = Alignment(ourMap(initPage, 0, _kTabs.length - 1, -1, 1), 0);
    _controller = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    )..addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });

    _searchHeightController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 0.5,
      duration: Duration(milliseconds: 200),
    );
    _searchHeightController.reverse();
    currentPage.listen((int page) {
      _runAnimation(
        _dragAlignment,
        Alignment(ourMap(page, 0, _kTabs.length - 1, -1, 1), 0),
      );
    });
    _recent = _recentSongs;
    _mostPlayedSongs = _mostPlayed;
    _fav = _favSongs;
    initNotificationListener();
    initPlayer();
  }


  void _runAnimation(Alignment oldA, Alignment newA) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: oldA,
        end: newA,
      ),
    );

    _controller.reset();
    _controller.forward();
  }
  
  
  
  void initNotificationListener(){

    MediaNotification.setListener('next',(){

      var songsList = ScopedModel.of<SongModel>(context).getSongsList;
      int currentIndex = ScopedModel.of<SongModel>(context).getIndex;
      bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
      setState(() {
        int selectedSong = currentIndex + 1;
        bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
        if(selectedSong != songsList.length -1 ){
          _audioPlayer.stop();
          _audioPlayer.play(songsList[selectedSong].uri);
          ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
        }
      });
    });
    
    MediaNotification.setListener('prev', (){
      var songsList = ScopedModel.of<SongModel>(context).getSongsList;
      int currentIndex = ScopedModel.of<SongModel>(context).getIndex;
      bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
      setState(() {
        int selectedSong = currentIndex - 1;
        if(selectedSong != -1 ){
          _audioPlayer.stop();
          _audioPlayer.play(songsList[selectedSong].uri);
          ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
        }
      });
    });

    MediaNotification.setListener('play', (){

      var songsList = ScopedModel.of<SongModel>(context).getSongsList;
      int currentIndex = ScopedModel.of<SongModel>(context).getIndex;
      bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
      setState(() {
        _audioPlayer.play(songsList[currentIndex].uri);
        isPlaying = true;
        ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
      });
    });

    MediaNotification.setListener('pause', (){

      var songsList = ScopedModel.of<SongModel>(context).getSongsList;
      bool isPlaying = ScopedModel.of<SongModel>(context).isPlayingSong;
      setState(() {
        _audioPlayer.pause();
        isPlaying = false;
        ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
      });
    });

  }
  
  

  initPlayer(){
    var songs = widget.songs;
    //_songs = List.from(songs);
    songs.sort((a,b) => a.title.compareTo(b.title));
    _audioPlayer.setCompletionHandler((){
        var songsList = ScopedModel.of<SongModel>(context).getSongsList;
        selectedSong = ScopedModel.of<SongModel>(context).getIndex + 1;
        if(selectedSong != songsList.length -1 ){
          _audioPlayer.play(songsList[selectedSong].uri);
          ScopedModel.of<SongModel>(context).updateSong(songsList[selectedSong], selectedSong, songsList, isPlaying);
        }
        songsList[selectedSong-1].timeStamp = DateTime.now().millisecondsSinceEpoch;
        DatabaseHelper database = DatabaseHelper();
        database.updateSong(songsList[selectedSong-1]);
        setState(() async{
          _recent = await database.getRecentSongs();
          _mostPlayedSongs = await database.getMostPlayedSongs();
        });
    });
    int recentIndex = 0;
    for(int i=0;i<songs.length;i++){
      if(songs[i].id == _recent[0].id){
        recentIndex = i;
        break;
      }
    }
    ScopedModel.of<SongModel>(context).updateSong(_recentSongs[0], recentIndex, songs, false);
  }

  void updateFavList(){
    DatabaseHelper database = DatabaseHelper();
    setState(() async{
      _fav = await database.getFavSongs();
    });
  }


  @override
  void dispose() {
    _currentPageSubject.close();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {

    final _kTabPages = <Widget>[
      _buildHome(),
      _buildSongList(),
      _buildAlbumList(),
      _buildPlaylistList(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(15,20,15,5),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.3),
                                  borderRadius:BorderRadius.all(
                                    Radius.circular(30)
                                  )
                                ),
                                child: Center(
                                  child: TextField(
                                    cursorRadius: Radius.circular(10),
                                    decoration: InputDecoration(
                                      border:InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      hintText: 'Search',
                                      hintStyle:TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: kQuicksand,
                                      ),
                                    ),
//                                    onTap: (){
//                                      _searchHeightController.animateTo(1);
//                                    },
                                    onSubmitted: (value){
                                      if(value.trim() == ""){
                                        searchResults = [];
                                        _searchHeightController.reverse();
                                      }
                                    },
                                    onChanged: (String value){
                                      if(value.trim() == ""){
                                        searchResults = [];
                                      }else{
                                        if(_searchHeightController.status != AnimationStatus.completed)
                                          _searchHeightController.forward();
                                        setState(() {
                                          searchResults = widget.songs
                                              .where((song){
                                            return
                                              song.title.toLowerCase().contains(value.toLowerCase()) ||
                                                  song.artist.toLowerCase().contains(value.toLowerCase()) ||
                                                  song.album.toLowerCase().contains(value.toLowerCase());
                                          }).toList();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            InkWell(
                              onTap: (){
                                if(_searchText != null){
                                  //TODO:
                                }
                              },
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              splashColor: Color(0xff7645c7),
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Colors.blueGrey,
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10,),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          child: Stack(
                            children: <Widget>[
                              StreamBuilder(
                                stream: currentPage,
                                builder: (context, AsyncSnapshot<int> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.active) {
                                    return AnimatedAlign(
                                      duration: kThemeAnimationDuration,
                                      alignment: Alignment(
                                          ourMap(snapshot.data, 0, _kTabs.length - 1, -0.98, 0.97),
                                          0),
                                      child: LayoutBuilder(
                                        builder: (BuildContext context,
                                            BoxConstraints constraints) {
                                          double width = constraints.maxWidth;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: Container(
                                              height: double.infinity,
                                              width: width / _kTabs.length - 4,
                                              decoration: BoxDecoration(
                                                color: Colors.blueGrey,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                },
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: _kTabs.map((text) {
                                    int index = _kTabs.indexOf(text);
                                    return Container(
                                      width: MediaQuery.of(context).size.width /_kTabs.length,
                                      child: MaterialButton(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        color: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        focusElevation: 0.0,
                                        hoverElevation: 0.0,
                                        elevation: 0.0,
                                        highlightElevation: 0.0,
                                        child: StreamBuilder(
                                            stream: currentPage,
                                            builder:
                                                (context, AsyncSnapshot<int> snapshot) {
                                              return AnimatedDefaultTextStyle(
                                                duration: kThemeAnimationDuration,
                                                style: TextStyle(
                                                  inherit: true,
                                                  color: snapshot.data == index
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                                child: Text(
                                                  text,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: kQuicksand,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }),
                                        onPressed: () {
                                          currentPageSink.add(index);
                                          _pageController.jumpToPage(index);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => currentPageSink.add(page),
                    children: <Widget>[
                      for (int i=0;i< _kTabs.length; i++)
                        _kTabPages[i]
                    ],
                  ),
                ),
              ],
            ),
            ScopedModelDescendant<SongModel>(
              builder: (context, child, model){

                isPlaying = model.song != null ? true : false;
                if(model.song != null){
                  MediaNotification.showNotification(title: model.song.title,author: model.song.artist,isPlaying: isPlaying);
                }
                return (model.song == null)?
                SizedBox():
                Positioned(
                  bottom: 0,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NowPlaying(
                            alreadyPlaying: model.isPlayingSong?model.isPlaying:false,
                            audioPlayer: _audioPlayer,
                            songs: model.getSongsList,
                            index: model.getIndex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      height: 75,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              radius: 25,
                              child: (model.song.albumArt == null)?
                              Icon(
                                Icons.music_note,
                                color: Colors.white,
                              ):ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image(
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  image: FileImage(File(model.song.albumArt)),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: ListTile(
                                title: Text(
                                  '${model.song.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: kQuicksand,
                                  ),
                                ),
                                subtitle: Text(
                                  '${model.song.artist}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontFamily: kQuicksand,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                MaterialCommunityIcons.skip_previous,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: (){
                                if(model.getIndex > 0){
                                  ScopedModel
                                      .of<SongModel>(context)
                                      .updateSong(
                                    model.songs[model.index-1],
                                    model.index-1,
                                    model.songs,
                                    model.isPlayingSong
                                  );
                                  _audioPlayer.stop();
                                  if(model.isPlayingSong)
                                    _audioPlayer.play(model.song.uri);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                model.isPlayingSong?
                                MaterialCommunityIcons.pause :
                                MaterialCommunityIcons.play,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () async {
                                if(model.isPlayingSong){
                                  await _audioPlayer.pause();
                                }else{
                                  await _audioPlayer.play(model.song.uri);
                                }
                                ScopedModel.of<SongModel>(context).updateSong(
                                  model.song,
                                  model.index,
                                  model.songs,
                                  !model.isPlayingSong
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                MaterialCommunityIcons.skip_next,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: (){
                                if(model.getIndex < model.getSongsList.length-1){
                                  ScopedModel
                                      .of<SongModel>(context)
                                      .updateSong(
                                    model.songs[model.index+1],
                                    model.index+1,
                                    model.songs,
                                    model.isPlayingSong,
                                  );
                                  _audioPlayer.stop();
                                  if(model.isPlayingSong)
                                    _audioPlayer.play(model.song.uri);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 70,
              child:Container(
                width: MediaQuery.of(context).size.width,
                height:(MediaQuery.of(context).size.height * _searchHeightController.value),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(MaterialCommunityIcons.arrow_left,color: Colors.white,),
                          onPressed: (){
                            setState(() {
                              _searchHeightController.reverse();
                            });
                          },
                        ),
                        Text(
                          'Search song, artist or album',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: kQuicksand,
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height:((MediaQuery.of(context).size.height - 200) * _searchHeightController.value),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (BuildContext context,int index){
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                            isThreeLine: true,
                            leading: CircleAvatar(
                              radius: 20,
                              child: !(searchResults[index].albumArt == null)?ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image(
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.fill,
                                  image: FileImage(
                                    File(searchResults[index].albumArt),
                                  ),
                                ),
                              ):Icon(Icons.music_note,color: Colors.white,),
                            ),
                            title: Text(
                              "${searchResults[index].title}",
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: kQuicksand,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            subtitle: Text(
                              "${searchResults[index].artist}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            onTap: ()async {
                              int selIndex = 0;
                              for(int i =0; i< _songs.length;i++){
                                if(_songs[i].id == searchResults[index].id){
                                  selIndex = i;
                                }
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: _audioPlayer, songs: _songs, index: selIndex,alreadyPlaying: false,)));
                              setState(() {
                                isPlaying = true;
                              });
                            },

                          );
                        },
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

  Widget _buildHome(){
    setState(() {
      _fav.shuffle();
    });
    Size size = MediaQuery.of(context).size;
    SongModel model = ScopedModel.of<SongModel>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom:(model.isPlayingSong??false)?0:100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (_recent.length != 0 && _recent[0].timeStamp != 0)?Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text(
              'Recently Played',
              style: TextStyle(
                fontFamily: kQuicksand,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ):SizedBox(),
          (_recent.length != 0 && _recent[0].timeStamp != 0)?Container(
            height: 100,
            width: size.width,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            child: PageView.builder(
              itemCount: _recent.length,
              controller: PageController(initialPage: 0, viewportFraction: 0.9),
              itemBuilder: (BuildContext context, int index){
                return (_recent[index].timeStamp == 0)?null:Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 20,
                      child: !(_recent[index].albumArt == null)?ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                          height: 40,
                          width: 40,
                          fit: BoxFit.fill,
                          image: FileImage(
                            File(_recent[index].albumArt),
                          ),
                        ),
                      ):Icon(Icons.music_note,color: Colors.white,),
                    ),
                    title: Text(
                      "${_recent[index].title}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: kQuicksand,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      "${_recent[index].artist}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    onTap: ()async {
                      selectedSong = index;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: _audioPlayer, songs: _recent, index: index,alreadyPlaying: false,)));
                      setState(() {
                        isPlaying = true;
                      });
                    },

                  ),
                );
              },
            ),
          ):SizedBox(),
          (_fav.length != 0)?Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text(
              'Favourites',
              style: TextStyle(
                fontFamily: kQuicksand,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ):SizedBox(),
          (_fav.length != 0)?Container(
            padding: EdgeInsets.only(top: 10,),
            height: size.width * 0.9,
            child: PageView.builder(
              itemCount: _fav.length,
              controller: PageController(initialPage: 0, viewportFraction: 0.8),
              itemBuilder: (BuildContext context, int index){
                return Column(
                  children: <Widget>[
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Container(
                          height: size.width * 0.7,
                          width: size.width * 0.8,
                          child: Image(
                            fit: BoxFit.cover,
                            image: !(_fav[index].albumArt == null)?
                            FileImage(File(_fav[index].albumArt),):
                            AssetImage(kAlbumArtLarge),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width:size.width*0.7,
                      margin:EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _fav[index].title,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: kQuicksand,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _fav[index].artist,
                            style: TextStyle(
                              fontFamily: kQuicksand,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ):SizedBox(),
          (_mostPlayedSongs.length != 0 && _mostPlayedSongs[0].timeStamp != 0)?Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text(
              'Most Played',
              style: TextStyle(
                fontFamily: kQuicksand,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ):SizedBox(),
          (_mostPlayedSongs.length != 0 && _mostPlayedSongs[0].timeStamp != 0)?Container(
            height: 100,
            width: size.width,
            padding: EdgeInsets.only(top: 10,bottom: 10),
            child: PageView.builder(
              itemCount: _mostPlayedSongs.length,
              controller: PageController(initialPage: 0, viewportFraction: 0.9),
              itemBuilder: (BuildContext context, int index){
                return (_mostPlayedSongs[index].count == 0)?null:Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 20,
                      child: !(_mostPlayedSongs[index].albumArt == null)?ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                          height: 40,
                          width: 40,
                          fit: BoxFit.fill,
                          image: FileImage(
                            File(_mostPlayedSongs[index].albumArt),
                          ),
                        ),
                      ):Icon(Icons.music_note,color: Colors.white,),
                    ),
                    title: Text(
                      "${_mostPlayedSongs[index].title}",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: kQuicksand,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Text(
                      "${_mostPlayedSongs[index].artist}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    onTap: ()async {
                      selectedSong = index;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: _audioPlayer, songs: _mostPlayedSongs, index: index,alreadyPlaying: false,)));
                      setState(() {
                        isPlaying = true;
                      });
                    },

                  ),
                );
              },
            ),
          ):SizedBox(),
        ],
      ),
    );
  }





  Widget _buildSongList(){

    return Stack(
      children: <Widget>[
        ScopedModelDescendant<SongModel>(
              builder: (context,child,model){
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: (model.song != null)? 100:0),
                    itemCount: _songs.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                        isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          radius: 20,
                          child: !(_songs[index].albumArt == null)?ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image(
                              height: 40,
                              width: 40,
                              fit: BoxFit.fill,
                              image: FileImage(
                                File(_songs[index].albumArt),
                              ),
                            ),
                          ):Icon(Icons.music_note,color: Colors.white,),
                        ),
                        title: Text(
                          "${_songs[index].title}",
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: kQuicksand,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        subtitle: Text(
                          "${_songs[index].artist}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        onTap: ()async {
                          selectedSong = index;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NowPlaying(audioPlayer: _audioPlayer, songs: _songs, index: index,alreadyPlaying: false,)));
                          setState(() {
                            isPlaying = true;
                          });
                        },

                      );
                    },
                  ),
            );
          },
        ),
        Positioned(
          bottom: (ScopedModel.of<SongModel>(context).songs == null)?
          25:100,
          right: 25,
          child: FloatingActionButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NowPlaying(
                    audioPlayer: _audioPlayer,
                    songs: _songs,
                    index: 0,
                    alreadyPlaying: false,
                  )
                ),
              );
            },
            child: Icon(
              MaterialCommunityIcons.play,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildAlbumList(){
    Map<String,List<Song>> albums = Map();
    List<String> albumNames = List();

    for(Song song in _songs){
      if(albums.containsKey(song.album)){
        albums[song.album].add(song);
      }else{
        albumNames.add(song.album);
        albums[song.album] = [song];
      }
    }

    albumNames.sort();

    return ScopedModelDescendant<SongModel>(
      builder: (context,child,model){
        return GridView.builder(
            padding: EdgeInsets.only(bottom: (model.song != null)? 100:0),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: albumNames.length,
            itemBuilder:(BuildContext context, int index){
              return InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlbumScreen(albums[albumNames[index]],_audioPlayer)
                      )
                  );
                },
                child: Container(
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Material(
                          color: Colors.grey[800],
                          child: Container(
                            width: MediaQuery.of(context).size.width/2 -30,
                            height: MediaQuery.of(context).size.width/2 - 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: !(albums[albumNames[index]][0].albumArt == null)?ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                              child: Image(
                                fit: BoxFit.cover,
                                image: FileImage(File(albums[albumNames[index]][0].albumArt)),
                              ),
                            ):Center(child: Icon(Icons.album,size: 70,color: Colors.white,)),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        width: MediaQuery.of(context).size.width/2 - 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        height: 50,
                        child: Center(
                          child: Text(
                            '${albumNames[index]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: kQuicksand,
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildPlaylistList(){

    return ScopedModelDescendant<SongModel>(
      builder: (context, child, model) {
        return ListView.builder(
          padding: EdgeInsets.only(bottom: (model.song != null)? 100:0),
          itemCount: 3,
          itemBuilder: (BuildContext context, int index){

            if(index == 0){
              return InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistScreen(_fav,_audioPlayer),
                    ),
                  );
                },
                child: Container(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 30,
                      child: (_fav.length != 0 && _fav[0].albumArt==null)?
                      Icon(
                        MaterialCommunityIcons.music_note,
                        color: Colors.white,
                      ):ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Image(
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill,
                          image: (_fav.length == 0)?AssetImage(kAlbumArtIcon):FileImage(
                              File(
                                _fav[0].albumArt,
                              )
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Favourites',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${_fav.length} songs',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }else if(_recent.length != 0 && index == 1){
              return InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistScreen(_recent,_audioPlayer),
                    ),
                  );
                },
                child: Container(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 30,
                      child: (_recent[0].albumArt==null)?
                      Icon(
                        MaterialCommunityIcons.music_note,
                        color: Colors.white,
                      ):ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Image(
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill,
                          image: FileImage(
                              File(
                                _recent[0].albumArt,
                              )
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Recently Played Songs',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${_recent.length} songs',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }else if(_mostPlayedSongs.length != 0 && index == 2){
              return InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistScreen(_mostPlayedSongs,_audioPlayer),
                    ),
                  );
                },
                child: Container(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      radius: 30,
                      child: (_mostPlayedSongs[0].albumArt==null)?
                      Icon(
                        MaterialCommunityIcons.music_note,
                        color: Colors.white,
                      ):ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Image(
                          height: 60,
                          width: 60,
                          fit: BoxFit.fill,
                          image: FileImage(
                              File(
                                _mostPlayedSongs[0].albumArt,
                              )
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Most Played Songs',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${_mostPlayedSongs.length} songs',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }else{
              return null;
            }
          },
        );
      },

    );
  }

}