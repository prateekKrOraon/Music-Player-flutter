import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:frequency_music_player/song_list_screen.dart';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'modals/song_modal.dart';
import 'over_scroll_behavior.dart';
import 'utility/database_helper.dart';

class SlidingScaffold extends StatefulWidget{

  final Widget menu;
  final Layout content;
  final MusicFinder audioPlayer;
  final List<Song> songs;
  final int index;
  final bool alreadyPlaying;

  SlidingScaffold({
    @required this.menu,
    @required this.content,
    @required this.audioPlayer,
    @required this.songs,
    @required this.index,
    @required this.alreadyPlaying
  });

  @override
  SlidingScaffoldState createState() {
    return SlidingScaffoldState(menu,content,alreadyPlaying);
  }

}

enum PlayerState { stopped, playing, paused }

class SlidingScaffoldState extends State<SlidingScaffold> with TickerProviderStateMixin{

  final Widget menu;
  final Layout content;
  final bool alreadyPlaying;

  SlidingScaffoldState(this.menu,this.content,this.alreadyPlaying);

  Curve slideOutCurve = Interval(0.0,1.0,curve: Curves.easeOut);
  Curve slideInCurve = Interval(0.0,1.0,curve: Curves.easeOut);

  bool hasAlbumArt;
  bool nextHasAlbumArt;

  Color controlsColor = Colors.blueGrey;
  Color textColor = Colors.black;
  Color backgroundColor = Colors.grey[900];

  DatabaseHelper _database;
  Duration duration;
  Duration position;

  MusicFinder audioPlayer;
  List<Song> songs;
  Song song;
  int playingIndex;
  int selectedIndex;
  SongModel current;
  PageController _albumArtController;

  PlayerState playerState = PlayerState.stopped;

  final double _bottomSheetCornerRadius = 20;

  AnimationController _bottomSheetController;

  bool isMuted = false;
  bool isShuffling = false;

  bool paused = false;


  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  double get halfScreen => MediaQuery.of(context).size.height / 2;

  double get fullScreen => MediaQuery.of(context).size.height-80;


  @override
  void initState() {
    super.initState();
    _database = DatabaseHelper();

    _bottomSheetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    Future.delayed(Duration(milliseconds: 400)).then((v) {
      _animateToInitial();
    });

    audioPlayer = widget.audioPlayer;
    if(!alreadyPlaying){
      audioPlayer.stop();
    }
    songs = widget.songs;
    playingIndex = widget.index;
    selectedIndex = playingIndex;
    song = songs[playingIndex];
    initPlayer();
    updatePreviousScreen(song,playingIndex,songs,true);
    if(!alreadyPlaying && ScopedModel.of<SongModel>(context).isPlayingSong) {
      initPlayer();
      if(!paused && ScopedModel.of<SongModel>(context).isPlayingSong){
        _playLocal(song.uri);
      }
    }else{
      if(ScopedModel.of<SongModel>(context).isPlayingSong){
        audioPlayer.play(song.uri);
      }
    }

    _albumArtController = PageController(initialPage: playingIndex,viewportFraction: 0.8);
  }

  void updatePreviousScreen(Song song,int index, List<Song> songs, bool isPlaying) {
    ScopedModel.of<SongModel>(context).updateSong(song,index,songs,isPlaying);
  }


  @override
  void dispose(){
    _bottomSheetController.dispose();
    super.dispose();
  }

  initPlayer(){

    audioPlayer.setDurationHandler((d) => setState(() {
      duration = d;
    }));

    audioPlayer.setPositionHandler((p) => setState(() {
      position = p;
    }));

//    audioPlayer.setCompletionHandler(() {
//      onComplete();
//      setState(() {
//        position = duration;
//      });
//    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }


  Future play(String kUrl) async {

    final result = await audioPlayer.play(kUrl);
    if (result == 1)
      setState(() {
        playerState = PlayerState.playing;
      });

  }

  Future pause() async {

    final result = await audioPlayer.pause();
    if (result == 1)
      setState(() {
        playerState = PlayerState.paused;
      });

  }

  Future prev() async {
    if(playingIndex !=0 ){
      playingIndex -= 1;
      setState(() {
        song = songs[playingIndex];
      });
      audioPlayer.stop();
      if(!paused)
        audioPlayer.play(song.uri);
      updatePreviousScreen(song,playingIndex,songs,!paused);
    }
  }

  Future next() async{
    if(playingIndex != songs.length-1){
      playingIndex += 1;
      setState(() {
        song = songs[playingIndex];
      });
      audioPlayer.stop();
      if(!paused)
        audioPlayer.play(song.uri);
    }
    updatePreviousScreen(song,playingIndex,songs,!paused);
  }

  Future _playLocal(String url) async {
    await audioPlayer.play(url, isLocal: true);
  }

  void onComplete() {

    setState(() {
      playingIndex +=1;
      song = songs[playingIndex];
    });
    updatePreviousScreen(song,playingIndex,songs,!paused);
    play(song.uri);
    //setState(() => playerState = PlayerState.stopped);
  }


  buildContent(Size size){
    return slideContent(
      content: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0,0),
                  blurRadius: 50,
                )
              ]
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(SimpleLineIcons.arrow_down),
                          color: Colors.white,
                          onPressed: (){
                            Navigator.pop(context,playingIndex);
                          },
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: Icon(SimpleLineIcons.menu),
                          color: Colors.white,
                          onPressed: (){
                            Provider.of<MenuController>(context,listen:true).toggle();
                          },
                          iconSize: 20,
                        )
                      ],
                    ),
                  ),
                ),//top Icons
                Positioned(
                  top: 50,
                  bottom: 0,
                  child: Container(
                    height: size.height - 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular((1 - _bottomSheetController.value) * _bottomSheetCornerRadius * 2,),
                        topRight: Radius.circular((1 - _bottomSheetController.value) * _bottomSheetCornerRadius * 2),
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: size.width * 0.1,
                            ),
                            GestureDetector(
                              onHorizontalDragEnd: (drag){
                                double v = drag.velocity.pixelsPerSecond.dx / size.width;
                                if(v<0){
                                  next();
                                }else{
                                  prev();
                                }
                              },
                              child: Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(20),
                                shadowColor: Colors.blueGrey,
                                child: Container(
                                  width: size.width * 0.8,
                                  height: size.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: controlsColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image(
                                      width: size.width * 0.8,
                                      height: size.height * 0.8,
                                      fit: BoxFit.cover,
                                      image: (songs[playingIndex].albumArt != null)?
                                      FileImage(File(songs[playingIndex].albumArt)):
                                      AssetImage(kAlbumArtLarge),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: size.width,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        song.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        //overflow: TextOverflow.fade,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontFamily: kQuicksand,
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Text(
                                        song.artist,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: textColor,
                                          fontFamily: kQuicksand,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              width: 25,
                                              child: Text(
                                                (((position?.inSeconds??0)%60) < 10)?
                                                '${position?.inMinutes??0}:0${(position?.inSeconds??0)%60}':
                                                '${position?.inMinutes??0}:${(position?.inSeconds??0)%60}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: kQuicksand,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Slider(
                                                min: 0.0,
                                                max: duration?.inMilliseconds?.toDouble()??1.0,
                                                value: position?.inMilliseconds?.toDouble()??0.0,
                                                onChanged: (double value){
                                                  audioPlayer.seek((value/1000).roundToDouble());
                                                },
                                              ),
                                            ),
                                            Container(
                                              width: 25,
                                              child: Text(
                                                (((duration?.inSeconds??0)%60) < 10)?
                                                '${duration?.inMinutes??0}:0${(duration?.inSeconds??0)%60}':
                                                '${duration?.inMinutes??0}:${(duration?.inSeconds??0)%60}',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontFamily: kQuicksand
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(MaterialCommunityIcons.skip_previous),
                                            iconSize: 40,
                                            color: controlsColor,
                                            onPressed: (){
                                              prev();
                                            },
                                          ),
                                          SizedBox(width: 10,),
                                          InkWell(
                                            onTap: (){
                                              if(!paused){
                                                paused = !paused;
                                                pause();
                                              }else{
                                                paused = !paused;
                                                play(song.uri);
                                              }
                                              ScopedModel.of<SongModel>(context).updateSong(
                                                song,
                                                playingIndex,
                                                songs,
                                                !paused,
                                              );
                                            },
                                            child: Container(
                                              height: size.width/5,
                                              width: size.width/5,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(size.width/10)),
                                                border: Border.all(
                                                  color: Theme.of(context).accentColor,
                                                  width: 2,
                                                )
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  ScopedModel.of<SongModel>(context).isPlayingSong?
                                                  MaterialCommunityIcons.pause:
                                                  MaterialCommunityIcons.play,
                                                  color: Theme.of(context).accentColor,
                                                  size: size.width/10,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          IconButton(
                                            icon: Icon(MaterialCommunityIcons.skip_next),
                                            iconSize: 40,
                                            color: controlsColor,
                                            onPressed: (){
                                              next();
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(isMuted?MaterialCommunityIcons.volume_variant_off:MaterialCommunityIcons.volume_high),
                                            iconSize: 20,
                                            color: controlsColor,
                                            onPressed: (){
                                              setState(() {
                                                isMuted = !isMuted;
                                                audioPlayer.mute(isMuted);
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(isShuffling?MaterialCommunityIcons.shuffle:MaterialCommunityIcons.shuffle_disabled,),
                                            iconSize: 20,
                                            color: controlsColor,
                                            onPressed: (){
                                              setState(() {
                                                if(!isShuffling){
                                                  isShuffling = !isShuffling;
                                                  songs.shuffle();
                                                  ScopedModel.of<SongModel>(context).isShuffling = true;
                                                  ScopedModel.of<SongModel>(context).updateSong(songs[playingIndex], playingIndex, songs, !paused);
                                                }else{
                                                  isShuffling = !isShuffling;
                                                  songs = widget.songs;
                                                  ScopedModel.of<SongModel>(context).isShuffling = false;
                                                  ScopedModel.of<SongModel>(context).updateSong(songs[playingIndex], playingIndex, songs, !paused);
                                                }
                                                audioPlayer.stop();
                                                audioPlayer.play(songs[playingIndex].uri);
                                              });
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(MaterialCommunityIcons.playlist_plus),
                                            iconSize: 20,
                                            color: controlsColor,
                                            onPressed: (){
                                              //TODO
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon((song.isFav == 0)?MaterialCommunityIcons.heart_outline:MaterialCommunityIcons.heart),
                                            iconSize: 20,
                                            color: controlsColor,
                                            onPressed: () async {
                                              if(song.isFav == 0){
                                                setState(() {
                                                  song.isFav = 1;
                                                });
                                                await _database.setFav(song);
                                                Provider.of<SongsListScreenState>(context).updateFavList();
                                              }else{
                                                setState(() {
                                                  song.isFav = 0;
                                                });
                                                await _database.removeFav(song);
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildSlidingBottomSheet(),
                      ],
                    ),
                  ),
                ),//Player
              ],
            ),
          ),
        ),
      ),
    );
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _bottomSheetController.value);

  void _animateToInitial() {
    _bottomSheetController.animateTo(0.05, duration: Duration(milliseconds: 250));
  }

  Widget _buildSlidingBottomSheet(){

    return AnimatedBuilder(
      animation: _bottomSheetController,
      builder: (context, child) {
        final double topMargin = 15;
        //double topMarginAnimatedValue = (1 - _bottomSheetController.value) * topMargin * 1.5;
        final radiusAnimatedValue = Radius.circular(
            (1 - _bottomSheetController.value) * _bottomSheetCornerRadius * 2);
        final double bottomSheetDragIndicatorWidth = 76;
        double bottomSheetDragIndicatorWidthUpdatedValue =
            (1 - _bottomSheetController.value) *
                (bottomSheetDragIndicatorWidth * 1);
        return Positioned(
          height: _bottomSheetController.value * fullScreen,
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: WillPopScope(
              onWillPop: () async {
                if (_bottomSheetController.value > 0.05) {
                  await _bottomSheetController.animateTo(0.05,
                      duration: Duration(milliseconds: 150));
                  return false;
                } else {
                  await _bottomSheetController.animateTo(0,
                      duration: Duration(milliseconds: 150));
                  return true;
                }
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: AnimatedContainer(
                  width: MediaQuery.of(context).size.width,
                  duration: Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius:
                      BorderRadius.vertical(top: radiusAnimatedValue),
                  ),
                  child: Stack(children: <Widget>[
                    AnimatedPositioned(
                      duration:  Duration(milliseconds: 200),
                      top: topMargin,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          height: 4,
                          width: bottomSheetDragIndicatorWidthUpdatedValue,
                        ),
                      ),
                    ),
                    _buildBottomSheetContent(),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  void _handleDragUpdate(DragUpdateDetails details) {
    double dragSpeedToScreenSizeRatio = details.primaryDelta / fullScreen;
    double bottomSheetUpdatedValue = _bottomSheetController.value - dragSpeedToScreenSizeRatio;
    if (bottomSheetUpdatedValue >= 0.05) {
      _bottomSheetController.value = bottomSheetUpdatedValue;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_bottomSheetController.isAnimating || _bottomSheetController.status == AnimationStatus.completed){
      return;
    }
    final double flingVelocity = details.velocity.pixelsPerSecond.dy / fullScreen;
    if (flingVelocity < 0.0) {
      _bottomSheetController.fling(velocity: math.max(0.5, -flingVelocity));
      if(_bottomSheetController.value < 0.5){
        _bottomSheetController.animateTo(
          0.5,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    } else if (flingVelocity > 0.0) {
      _bottomSheetController.animateTo(
          0.05,
          duration: Duration(milliseconds: 100),
          curve: Curves.linear
      );
    } else {
      _animateToInitial();
    }
  }


  Widget _buildBottomSheetContent(){

    final double topPaddingMax = 44;
    double listContainerHeight = _bottomSheetController.value * fullScreen;
    final double topPaddingMin = MediaQuery.of(context).padding.top;
    double topMarginAnimatedValue = (1 - _bottomSheetController.value) * topPaddingMax * 1;
    double topMarginUpdatedValue = topMarginAnimatedValue <= topPaddingMin ? topPaddingMin : topMarginAnimatedValue;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: Padding(
        padding:  EdgeInsets.only(top: topMarginUpdatedValue),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ScrollConfiguration(
              behavior: OverScrollBehavior(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Stack(
                    children: <Widget>[
                      (listContainerHeight <= 50)?SizedBox():Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          top: 5,
                          bottom: 5
                        ),
                        child: Text(
                          'Queue',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: kQuicksand,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      ((playingIndex+1)>=songs.length && listContainerHeight <= 110)?SizedBox():Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Container(
                          height: (listContainerHeight <= 50)?0:listContainerHeight,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            itemCount: this.songs.length - this.selectedIndex,
                            itemBuilder: (BuildContext context, int index){

                              if(index + this.playingIndex >= this.songs.length){
                                return SizedBox();
                              }
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).accentColor,
                                  radius: 15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: (songs[this.selectedIndex + index].albumArt != null)?Image(
                                        height: 30,
                                        width: 30,
                                        fit: BoxFit.fill,
                                        image: FileImage(
                                          File(songs[this.selectedIndex + index].albumArt),
                                        )
                                    ):Center(child: Icon(Icons.music_note,color: Colors.white,size: 18,),),
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${songs[this.selectedIndex + index].title}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontFamily: kQuicksand,
                                      ),
                                    ),
                                    Text(
                                      '${songs[this.selectedIndex + index].artist}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontFamily: kQuicksand,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: (index + selectedIndex == playingIndex)?
                                  Icon(
                                    MaterialCommunityIcons.play,
                                    color: Colors.white,
                                  ):SizedBox(),
                                onTap: (){
                                  if(this.selectedIndex != songs.length-1){
                                    this.playingIndex = this.selectedIndex+index;
                                    setState(() {
                                      song = songs[this.playingIndex];
                                    });
                                    audioPlayer.stop();
                                    audioPlayer.play(song.uri);
                                    updatePreviousScreen(song,playingIndex,songs,!paused);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  slideContent({Widget content}){
    var slidePercent;
    switch(Provider.of<MenuController>(context,listen: true).state){
      case MenuState.closed:
        slidePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(
          Provider.of<MenuController>(context,listen: true).percentOpen
        );
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(
          Provider.of<MenuController>(context,listen: true).percentOpen
        );
        break;
    }

    final slideAmount = (MediaQuery.of(context).size.width * 0.8) * slidePercent;

    return Transform(
      transform: Matrix4.translationValues(-slideAmount, 0.0, 0.0),
      alignment: Alignment.centerRight,
      child: Container(
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      current = ScopedModel.of<SongModel>(context);
    });

    song = current.getSong;
    songs = current.getSongsList;
    paused = !current.isPlayingSong??false;
    playingIndex = current.getIndex;
    hasAlbumArt = song.albumArt != null;
    nextHasAlbumArt = ((playingIndex + 1)< songs.length-1 && songs[playingIndex+1].albumArt != null);
    isShuffling = current.isShuffling??false;
    updatePreviousScreen(song, playingIndex, songs, !paused);

    if(song.albumArt == null)
      hasAlbumArt = false;
    else
      hasAlbumArt = true;

    if((playingIndex+1) < songs.length && songs[playingIndex+1].albumArt == null){
      nextHasAlbumArt = false;
    }else{
      nextHasAlbumArt = true;
    }

    Size size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        Container(
          child: Scaffold(
            body: menu,
          ),
        ),
        buildContent(size),
      ],
    );
  }

  
}

class SlidingScaffoldMenuController extends StatefulWidget{

  final SlidingScaffoldBuilder builder;
  SlidingScaffoldMenuController({this.builder});

  @override
  SlidingScaffoldMenuControllerState createState() {
    return SlidingScaffoldMenuControllerState();
  }

}

class SlidingScaffoldMenuControllerState extends State<SlidingScaffoldMenuController>{
  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      Provider.of<MenuController>(context,listen: true),
    );
  }
}

typedef Widget SlidingScaffoldBuilder(BuildContext context, MenuController menuController);

class Layout {
  final WidgetBuilder content;

  Layout({
    this.content,
  });
}

class MenuController extends ChangeNotifier{

  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }):_animationController = AnimationController(vsync: vsync){
    _animationController
      ..duration = Duration(milliseconds: 250)
      ..addListener((){
        notifyListeners();
    })
    ..addStatusListener((AnimationStatus status){
      switch(status){
        case AnimationStatus.forward:
          state = MenuState.opening;
          break;
        case AnimationStatus.reverse:
          state = MenuState.closing;
          break;
        case AnimationStatus.completed:
          state = MenuState.open;
          break;
        case AnimationStatus.dismissed:
          state = MenuState.closed;
          break;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  get percentOpen{
    return _animationController.value;
  }

  open(){
    _animationController.forward();
  }

  close(){
    _animationController.reverse();
  }

  toggle(){
    if(state == MenuState.open){
      close();
    }else if(state == MenuState.closed){
      open();
    }
  }
}

enum MenuState {
  closed,
  opening,
  open,
  closing
}