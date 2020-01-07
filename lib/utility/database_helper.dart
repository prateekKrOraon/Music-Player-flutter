import 'dart:async';
import 'package:frequency_music_player/utility/constants.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper{

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper(){
    return _instance;
  }

  DatabaseHelper._internal();

  static Database _database;

  Future<Database> get database async{
    if(_database != null){
      return _database;
    }

    _database = await initDataBase();
    return _database;
  }

  initDataBase() async {
    String documentDir = await getDatabasesPath();
    String path = join(documentDir,'main.db');

    _database = await openDatabase(path,version: 1,onCreate: _onCreate);

  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE songs(id INTEGER PRIMARY KEY,title TEXT,artist TEXT,albumId INTEGER,album TEXT,albumArt TEXT,duration INTEGER,isFav INTEGER NOT NULL default 0,timeStamp INTEGER NOT NULL default 0,count INTEGER NOT NULL default 0, uri TEXT)");
  }

  Future<int> insertSongsIntoDatabase(Song song) async {
    if(song.isFav == null){
      song.isFav = 0;
    }
    if(song.timeStamp == null){
      song.timeStamp = 0;
    }
    if(song.count == null){
      song.count = 0;
    }

    int id = 0;
    var count = Sqflite.firstIntValue(
      await _database.rawQuery("SELECT COUNT(*) FROM songs WHERE id = ?",[song.id])
    );

    if(count == 0){
      id = await _database.insert("songs", song.toMap());
    }else{
      id = await _database.update("songs", song.toMap(),where: "id= ?",whereArgs: [song.id]);
    }
    return id;
  }

  Future<int> updateList(Song song) async {
    if(song.isFav == null){
      song.isFav = 0;
    }
    if(song.timeStamp == null){
      song.timeStamp = 0;
    }
    if(song.count == null){
      song.count = 0;
    }

    int id = 0;

    var count = Sqflite.firstIntValue(
      await _database.rawQuery("SELECT COUNT(*) FROM $kSongs WHERE id=?",[song.id]),
    );
    if(count == 0){
      _database.insert(kSongs, song.toMap());
    }

    return id;
  }

  Future<bool> isDatabaseCreated() async{
    var count = Sqflite.firstIntValue(await _database.rawQuery("SELECT COUNT(*) FROM songs"));
    if(count > 0){
      return true;
    }else{
      return false;
    }
  }

  Future<List<Song>> fetchAllSongs() async{
    List<Map> list = await _database.query("songs",columns: Song.columns,orderBy: kTitle);

    List<Song> songs = List();
    list.forEach((map) {
      Song song = Song.fromMap(map);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> getRecentSongs() async{
    List<Map> list = await _database.rawQuery("SELECT * FROM $kSongs ORDER BY $kTimeStamp DESC LIMIT 25");

    List<Song> songs = List();
    list.forEach((map){
      Song song = Song.fromMap(map);
      songs.add(song);
    });
    return songs;

  }

  Future<bool> setFav(Song song) async{
    await _database.rawQuery("UPDATE $kSongs SET $kIsFav = 1 WHERE $kId = ${song.id}");
    return true;
  }

  Future<Song> getLastPlayedSong() async{
    List<Map> list = await _database.rawQuery("SELECT * FROM $kSongs ORDER BY $kTimeStamp DESC LIMIT 1");
    Song song;
    list.forEach((map) {
      song = Song.fromMap(map);
    });

    return song;
  }

  Future<List<Song>> getFavSongs()async{
    List<Map> list = await _database.rawQuery("SELECT * FROM $kSongs WHERE $kIsFav=1");
    List<Song> songs = List();
    list.forEach((item){
      Song song = Song.fromMap(item);
      songs.add(song);
    });
    return songs;
  }

  Future<bool> removeFav(Song song)async{
    await _database.rawQuery("UPDATE $kSongs SET $kIsFav = 0 WHERE $kId = ${song.id}");
    return true;
  }

  Future<List<Song>> searchSongs(String query)async{
    List<Map> list = await _database.rawQuery("SELECT * FROM $kSongs WHERE $kTitle LIKE '%$query'%");
    List<Song> songs = List();
    list.forEach((item){
      Song song = Song.fromMap(item);
      songs.add(song);
    });
    return songs;
  }

  Future<bool> updateSong(Song song)async{
    song.count = song.count + 1;
    await _database.rawQuery("UPDATE $kSongs SET $kTimeStamp = ${song.timeStamp},$kCount = ${song.count} WHERE $kId = ${song.id}");
    return true;
  }

  Future<List<Song>> getMostPlayedSongs()async{
    List<Map> list = await _database.rawQuery("SELECT * FROM $kSongs ORDER BY $kCount DESC LIMIT 25");
    List<Song> songs = List();
    list.forEach((item){
      Song song = Song.fromMap(item);
      songs.add(song);
    });
    return songs;
  }

}