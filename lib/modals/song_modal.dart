import 'package:flute_music_player/flute_music_player.dart';
import 'package:scoped_model/scoped_model.dart';

class SongModel extends Model{

  Song song;
  int index;
  List<Song> songs;
  bool isPlaying = false;
  bool isShuffling;

  bool get isPlayingSong => isPlaying;
  List<Song> get getSongsList => songs;
  Song get getSong => song;
  int get getIndex => index;

  void updateSong(Song song,int index,List<Song> songs,bool isPlaying){
    this.song = song;
    this.index = index;
    this.songs = songs;
    this.isPlaying = isPlaying;
    notifyListeners();
  }

}