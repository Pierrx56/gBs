import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DrawCharts.dart';

String KEY_USER_ID = "user_id";
String KEY_USER_NAME = "user_name";
String KEY_USER_MODE = "user_mode";
String KEY_USER_PIC = "user_pic";
String KEY_USER_HEIGHT_TOP = "user_height_top";
String KEY_USER_HEIGHT_BOTTOM = "user_height_bottom";
String KEY_USER_INITIAL_PUSH = "user_initial_push";
String KEY_USER_MAC_ADDRESS = "user_mac_address";

String KEY_SCORE_ID = "score_id";
String KEY_SCORE_DATE = "score_date";
String KEY_SCORE_VALUE = "score_value";

String KEY_ACTIVITY_ID = "activity_id";
String KEY_ACTIVITY_TYPE = "activity_type";
String KEY_ACTIVITY_NAME = "activity_name";
String KEY_ACTIVITY_DESCRIPTION = "activity_description";

String TABLE_USER = "User";
String TABLE_SCORE = "Score";
String TABLE_ACTIVITY = "Activity";

String DATABASE_NAME = "gBs_database";
int DATABASE_VERSION = 1;

final String CREATE_TABLE_USERS = "CREATE TABLE " +
    TABLE_USER +
    "(" +
    KEY_USER_ID +
    " INTEGER PRIMARY KEY AUTOINCREMENT, " +
    KEY_USER_NAME +
    " TEXT, " +
    KEY_USER_MODE +
    " TEXT, " +
    KEY_USER_PIC +
    " TEXT, " +
    KEY_USER_HEIGHT_TOP +
    " TEXT, " +
    KEY_USER_HEIGHT_BOTTOM +
    " TEXT, " +
    KEY_USER_INITIAL_PUSH +
    " TEXT, " +
    KEY_USER_MAC_ADDRESS +
    " TEXT" +
    ");";

final String CREATE_TABLE_SCORE = "CREATE TABLE " +
    TABLE_SCORE +
    "(" +
    KEY_SCORE_ID +
    " INTEGER PRIMARY KEY AUTOINCREMENT," +
    KEY_USER_ID +
    " INTEGER, " +
    KEY_ACTIVITY_ID +
    " INTEGER, " +
    KEY_SCORE_DATE +
    " TEXT, " +
    KEY_SCORE_VALUE +
    " INTEGER" +
    ");";

final String CREATE_TABLE_ACTIVITY = "CREATE TABLE " +
    TABLE_ACTIVITY +
    "(" +
    KEY_ACTIVITY_ID +
    " INTEGER PRIMARY KEY AUTOINCREMENT," +
    KEY_ACTIVITY_TYPE +
    " INTEGER, " +
    KEY_ACTIVITY_NAME +
    " TEXT, " +
    KEY_ACTIVITY_DESCRIPTION +
    " TEXT" +
    ");";

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  //void DatabaseManager() async {
  Future<Database> initializeDatabase() async {
    var todoDatabase = openDatabase(
      join(await getDatabasesPath(), DATABASE_NAME),
      onCreate: (db, version) {
        db.execute(CREATE_TABLE_USERS);
        db.execute(CREATE_TABLE_SCORE);
        db.execute(CREATE_TABLE_ACTIVITY);
      },
      version: 1,
    );
    return todoDatabase;
  }

  //USER
  //Define a function that inserts users into the database
  Future<int> addUser(User user) async {
    // Get a reference to the database.
    final Database db = await database;

    // In this case, replace any previous data.
    int id = await db.insert(
      TABLE_USER,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // A method that retrieves all the users from the users table.
  Future<List<User>> userList() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Users.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_USER);

    // Convert the List<Map<String, dynamic> into a List<User>.
    return List.generate(maps.length, (i) {
      print(maps[i]);
      return User(
        userId: maps[i][KEY_USER_ID],
        userName: maps[i][KEY_USER_NAME],
        userMode: maps[i][KEY_USER_MODE],
        userPic: maps[i][KEY_USER_PIC],
        userHeightTop: maps[i][KEY_USER_HEIGHT_TOP],
        userHeightBottom: maps[i][KEY_USER_HEIGHT_BOTTOM],
        userInitialPush: maps[i][KEY_USER_INITIAL_PUSH],
        userMacAddress: maps[i][KEY_USER_MAC_ADDRESS],
      );
    });
  }

  Future<void> updateUser(User user) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given User.
    await db.update(
      TABLE_USER,
      user.toMap(),
      // Ensure that the User has a matching id.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [user.userId],
    );
  }

  Future<void> deleteUser(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the User from the Database.
    await db.delete(
      TABLE_USER,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );    // Remove the User from the Database.

    await db.delete(
      TABLE_SCORE,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // A method that retrieves all the users from the users table.
  Future<User> getUser(int id) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Users.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_USER);

    // Convert the List<Map<String, dynamic> into a List<User>.

    List<User> user = List.generate(maps.length, (i) {
      print(maps[i]);

      return User(
        userId: maps[i][KEY_USER_ID],
        userName: maps[i][KEY_USER_NAME],
        userMode: maps[i][KEY_USER_MODE],
        userPic: maps[i][KEY_USER_PIC],
        userHeightTop: maps[i][KEY_USER_HEIGHT_TOP],
        userHeightBottom: maps[i][KEY_USER_HEIGHT_BOTTOM],
        userInitialPush: maps[i][KEY_USER_INITIAL_PUSH],
        userMacAddress: maps[i][KEY_USER_MAC_ADDRESS],
      );
    });

    for (int i = 0; i < maps.length; i++) {
      if (user[i].userId == id) id = i;
    }

    return user[id];
  }

  //END USER

  //SCORE
  //Define a function that inserts scores into the database
  Future<int> addScore(Score score) async {
    // Get a reference to the database.
    final Database db = await database;

    // In this case, replace any previous data.
    int id = await db.insert(
      TABLE_SCORE,
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }


  // A method that retrieves all the scores from the scores table.
  Future<List<Scores>> getScore(int id) async{
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Scores.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_SCORE);

    // Convert the List<Map<String, dynamic> into a List<Score>.
    List<Score> score = List.generate(maps.length, (i) {
      print(maps[i]);

      return Score(
        scoreId: maps[i][KEY_SCORE_ID],
        userId: maps[i][KEY_USER_ID],
        activityId: maps[i][KEY_ACTIVITY_ID],
        scoreDate: maps[i][KEY_SCORE_DATE],
        scoreValue: maps[i][KEY_SCORE_VALUE],

      );
    });

    int j, k = 0;

    List<Scores> data = [];

    for (int i = 0; i < maps.length; i++) {

      if (score[i].userId == id) {
        data.add(new Scores(score[i].scoreDate, score[i].scoreValue));
      }

    }

    return data;
    //return score[id];
  }


  //END SCORE


  //ACTIVITY
  //Define a function that inserts users into the database
  Future<int> addActivity(Activity activity) async {
    // Get a reference to the database.
    final Database db = await database;

    // In this case, replace any previous data.
    int id = await db.insert(
      TABLE_ACTIVITY,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }


  //END ACTIVITY
}

class User {
  final int userId;
  final String userName;
  final String userMode;
  final String userPic;
  final String userHeightTop;
  final String userHeightBottom;
  final String userInitialPush;
  final String userMacAddress;

  User({
    this.userId,
    this.userName,
    this.userMode,
    this.userPic,
    this.userHeightTop,
    this.userHeightBottom,
    this.userInitialPush,
    this.userMacAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      KEY_USER_ID: userId,
      KEY_USER_NAME: userName,
      KEY_USER_MODE: userMode,
      KEY_USER_PIC: userPic,
      KEY_USER_HEIGHT_TOP: userHeightTop,
      KEY_USER_HEIGHT_BOTTOM: userHeightBottom,
      KEY_USER_INITIAL_PUSH: userInitialPush,
      KEY_USER_MAC_ADDRESS: userMacAddress,
    };
  }
}

class Score {
  final int scoreId;
  final int userId;
  final int activityId;
  final String scoreDate;
  final int scoreValue;

  Score(
      {this.scoreId,
      this.userId,
      this.activityId,
      this.scoreDate,
      this.scoreValue});

  Map<String, dynamic> toMap() {
    return {
      KEY_SCORE_ID: scoreId,
      KEY_USER_ID: userId,
      KEY_ACTIVITY_ID: activityId,
      KEY_SCORE_DATE: scoreDate,
      KEY_SCORE_VALUE: scoreValue,
    };
  }
}



//ACTIVITY
class Activity {
  final int activityId;
  final String activityType;
  final String activityName;
  final String activitydescription;

  Activity(
      {this.activityId,
      this.activityType,
      this.activityName,
      this.activitydescription});

  Map<String, dynamic> toMap() {
    return {
      KEY_ACTIVITY_ID: activityId,
      KEY_ACTIVITY_TYPE: activityType,
      KEY_ACTIVITY_NAME: activityName,
      KEY_ACTIVITY_DESCRIPTION: activitydescription
    };
  }
}

/*
  createDatabase() async {
  String databasesPath = await getDatabasesPath();
  String dbPath = join(databasesPath, 'gBsDatabase.db');

  var database = await openDatabase(dbPath, version: 1, onCreate: gBsDb);
  return database;
  }

  void gBsDb(Database database, int version) async {
  await database.execute("CREATE TABLE User ("
  "user_id INTEGER PRIMARY KEY,"
  "user_name TEXT,"
  "user_mode TEXT,"
  "user_pic TEXT,"
  "user_height_top TEXT,"
  "user_height_down TEXT"
  ")");

  await database.execute("CREATE TABLE Score ("
  "score_id INTEGER PRIMARY KEY,"
  "user_id INTEGER,"
  "activity_id INTEGER,"
  "score_date TEXT,"
  "score_value INTEGER,"
  ")");

  await database.execute("CREATE TABLE Activity ("
  "activity_id INTEGER PRIMARY KEY,"
  "activity_type INTEGER,"
  "activity_name TEXT,"
  "activity_description TEXT,"
  ")");
  }

  class User {
  int userID;
  String userName;
  String userMode;
  String userPic;
  String userHeightTop;
  String userHeightDown;

  User({
  this.userID,
  this.userName,
  this.userMode,
  this.userPic,
  this.userHeightTop,
  this.userHeightDown,
  });


  int get _userID => userID;
  String get _userName => userName;
  String get _userMode => userMode;
  String get _userPic => userPic;
  String get _userHeightTop => userHeightTop;
  String get _userHeightDown => userHeightDown;


  factory User.fromJson(Map<String, dynamic> data) => new User(
  userID: data["user_id"],
  userName: data["user_name"],
  userMode: data["user_mode"],
  userPic: data["user_pic"],
  userHeightTop: data["user_height_top"],
  userHeightDown: data["user_height_down"],
  );

  Map<String, dynamic> toJson() => {
  "user_id": userID,
  "user_name": userName,
  "user_mode": userMode,
  "user_pic": userPic,
  "user_height_top": userHeightTop,
  "user_height_down": userHeightDown,
  };
  }

 */