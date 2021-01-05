import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DrawCharts.dart';

String KEY_ACTIVITY_ID = "activity_id";
String KEY_ACTIVITY_TYPE = "activity_type";
String KEY_ACTIVITY_NAME = "activity_name";
String KEY_ACTIVITY_DESCRIPTION = "activity_description";

String KEY_SCORE_ID = "score_id";
String KEY_SCORE_DATE = "score_date";
String KEY_SCORE_VALUE = "score_value";

String KEY_STAR_ID = "star_id";
String KEY_STAR_LEVEL = "star_level";
String KEY_STAR_VALUE = "star_value";

String KEY_USER_ID = "user_id";
String KEY_USER_NAME = "user_name";
String KEY_USER_MODE = "user_mode";
String KEY_USER_PIC = "user_pic";
String KEY_USER_HEIGHT_TOP = "user_height_top";
String KEY_USER_HEIGHT_BOTTOM = "user_height_bottom";
String KEY_USER_INITIAL_PUSH = "user_initial_push";
String KEY_USER_MAC_ADDRESS = "user_mac_address";
String KEY_USER_SERIAL = "user_serial_number";
String KEY_USER_NOTIF_EVENT = "user_notif_event";
String KEY_USER_LAST_LOGIN = "user_last_login";

String TABLE_ACTIVITY = "Activity";
String TABLE_SCORE = "Score";
String TABLE_STAR = "Star";
String TABLE_USER = "User";

String DATABASE_NAME = "gBs_database";
int DATABASE_VERSION = 1;

const int ID_SWIMMER_ACTIVITY = 0;
const int ID_PLANE_ACTIVITY = 1;
const int ID_TEMP_ACTIVITY = 2;

//https://dbdiagram.io/d/5f2c6c6808c7880b65c5621a

final String CREATE_TABLE_ACTIVITY = "CREATE TABLE " +
    TABLE_ACTIVITY +
    "(" +
    KEY_ACTIVITY_ID +
    " INTEGER PRIMARY KEY," +
    KEY_ACTIVITY_TYPE +
    " TEXT"
        /*+
    KEY_ACTIVITY_NAME +
    " TEXT, " +
    KEY_ACTIVITY_DESCRIPTION +
    " TEXT" +*/
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

final String CREATE_TABLE_STAR = "CREATE TABLE " +
    TABLE_STAR +
    "(" +
    KEY_STAR_ID +
    " INTEGER PRIMARY KEY AUTOINCREMENT," +
    KEY_ACTIVITY_ID +
    " INTEGER, " +
    KEY_USER_ID +
    " INTEGER, " +
    KEY_STAR_LEVEL +
    " INTEGER, " +
    KEY_STAR_VALUE +
    " REAL" +
    ");";

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
    " TEXT, " +
    KEY_USER_SERIAL +
    " TEXT, " +
    KEY_USER_NOTIF_EVENT +
    " TEXT, " +
    KEY_USER_LAST_LOGIN +
    " TEXT" +
    ");";

/*Classe qui gère la base de données
* */
class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  //Constructeur
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

      //Nageur
      addActivity(new Activity(
        activityId: 0,
        activityType: "CMV",
      ));
      //Avion
      addActivity(new Activity(
        activityId: 1,
        activityType: "CSI",
      ));
      //Troisième activité
      addActivity(new Activity(
        activityId: 2,
        activityType: "CSI",
      ));
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var todoDatabase = openDatabase(
        join(await getDatabasesPath(), DATABASE_NAME),
        version: DATABASE_VERSION,
        //Lors du premier lancement de l'appli
        onCreate: (db, version) {
          db.execute(CREATE_TABLE_ACTIVITY);
          db.execute(CREATE_TABLE_SCORE);
          db.execute(CREATE_TABLE_STAR);
          db.execute(CREATE_TABLE_USERS);
        },
        //TODO à tester
        //Si la structure de la table change lors d'une MàJ, cette fonction est appelée
        //Variable DATABASE_VERSION à changer plus haut
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < newVersion) {
            //Ne mettre que l'execute qui change qq chose
            //db.execute(CREATE_TABLE_ACTIVITY);
            //db.execute(CREATE_TABLE_SCORE);
            //db.execute(CREATE_TABLE_STAR);
            //db.execute(CREATE_TABLE_USERS);

          }
        });

    return todoDatabase;
  }

  //ACTIVITY
  //Define a function that inserts activity into the database
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

  //Useless ?
  Future<void> deleteActivity(int idActivity) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.delete(
      TABLE_ACTIVITY,
      // Use a `where` clause to delete a specific activity.
      where: KEY_ACTIVITY_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [idActivity],
    );
  }

  //END ACTIVITY

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
  Future<List<Scores>> getScore(int userId, int activityId) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Scores.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_SCORE);

    // Convert the List<Map<String, dynamic> into a List<Score>.
    List<Score> score = List.generate(maps.length, (i) {
      //maps[i]);

      return Score(
        scoreId: maps[i][KEY_SCORE_ID],
        userId: maps[i][KEY_USER_ID],
        activityId: maps[i][KEY_ACTIVITY_ID],
        scoreDate: maps[i][KEY_SCORE_DATE],
        scoreValue: maps[i][KEY_SCORE_VALUE],
      );
    });

    int j,
        k = 0;

    List<Scores> data = [];

    for (int i = 0; i < maps.length; i++) {
      if (score[i].userId == userId && score[i].activityId == activityId) {
        data.add(Scores(score[i].scoreId, score[i].activityId, score[i].userId,
            score[i].scoreDate, score[i].scoreValue));
      }
    }

    return data;
    //return score[id];
  }

  Future<void> updateScore(Score score) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given score.
    await db.update(
      TABLE_SCORE,
      score.toMap(),
      // Ensure that the score has a matching id.
      where: KEY_SCORE_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [score.scoreId],
    );
  }

  Future<void> deleteScore(int idUser) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.delete(
      TABLE_SCORE,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [idUser],
    );
  }

  //END SCORE

  //Star
  //Define a function that inserts star into the database
  Future<int> addStar(Star star) async {
    // Get a reference to the database.
    final Database db = await database;

    // In this case, replace any previous data.
    int id = await db.insert(
      TABLE_STAR,
      star.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // A method that retrieves all the scores from the star table.
  Future<Star> getStar(int userId, int activityId, int starLevel) async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Stars.
    final List<Map<String, dynamic>> maps = await db.query(TABLE_STAR);

    // Convert the List<Map<String, dynamic> into a List<Star>.
    List<Star> star = List.generate(maps.length, (i) {
      //maps[i]);
      return Star(
        starId: maps[i][KEY_STAR_ID],
        activityId: maps[i][KEY_ACTIVITY_ID],
        userId: maps[i][KEY_USER_ID],
        starLevel: maps[i][KEY_STAR_LEVEL],
        starValue: maps[i][KEY_STAR_VALUE],
      );
    });

    int j,
        k = 0;

    Star data;

    //Recherche de la bonne info
    for (int i = 0; i < maps.length; i++) {
      if (star[i].userId == userId && star[i].activityId == activityId && star[i].starLevel == starLevel) {
        //print(star[i].starValue);
        data = star[i];
        //data.add(Scores(score[i].scoreId, score[i].activityId, score[i].userId,
        //    score[i].scoreDate, score[i].scoreValue));
      }
    }

    return data;
    //return score[id];
  }

  Future<void> updateStar(Star star) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given score.
    await db.update(
      TABLE_STAR,
      star.toMap(),
      // Ensure that the star has a matching id.
      where: KEY_STAR_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [star.starId],
    );
  }

  Future<void> deleteStar(int idUser) async {
    // Get a reference to the database.
    final Database db = await database;

    await db.delete(
      TABLE_STAR,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [idUser],
    );
  }

  //END SCORE

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
        userSerialNumber: maps[i][KEY_USER_SERIAL],
        userNotifEvent: maps[i][KEY_USER_NOTIF_EVENT],
        userLastLogin: maps[i][KEY_USER_LAST_LOGIN],
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

    // Remove the score's User from the Database.
    await db.delete(
      TABLE_SCORE,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );

    // Remove the star's User from the Database.
    await db.delete(
      TABLE_STAR,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );

    // Remove the User from the Database.
    await db.delete(
      TABLE_USER,
      // Use a `where` clause to delete a specific user.
      where: KEY_USER_ID + " = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    ); // Remove the User from the Database.
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
        userSerialNumber: maps[i][KEY_USER_SERIAL],
        userNotifEvent: maps[i][KEY_USER_NOTIF_EVENT],
        userLastLogin: maps[i][KEY_USER_LAST_LOGIN],
      );
    });

    for (int i = 0; i < maps.length; i++) {
      if (user[i].userId == id) id = i;
    }

    return user[id];
  }

  //END USER

}

/*Classe Activity*/
class Activity {
  final int activityId;

  //CMV : Contraction maximale volontaire
  //CSI: Contraction spontanée intermittent
  final String activityType;

  /*
  final String activityName;
  final String activityDescription;*/

  Activity({
    this.activityId,
    this.activityType,
    /*
      this.activityName,
      this.activityDescription*/
  });

  Map<String, dynamic> toMap() {
    return {
      KEY_ACTIVITY_ID: activityId,
      KEY_ACTIVITY_TYPE: activityType,
      /*
      KEY_ACTIVITY_NAME: activityName,
      KEY_ACTIVITY_DESCRIPTION: activityDescription*/
    };
  }
}

/*Classe Score*/
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

/*Classe Star*/
class Star {
  final int starId;
  final int activityId;
  final int userId;
  final int starLevel;
  final double starValue;

  Star(
      {this.starId,
        this.activityId,
        this.userId,
      this.starLevel,
      this.starValue});

  Map<String, dynamic> toMap() {
    return {
      KEY_STAR_ID: starId,
      KEY_ACTIVITY_ID: activityId,
      KEY_USER_ID: userId,
      KEY_STAR_LEVEL: starLevel,
      KEY_STAR_VALUE: starValue,
    };
  }
}

/*Classe User*/
class User {
  final int userId;
  final String userName;
  final String userMode;
  final String userPic;
  final String userHeightTop;
  final String userHeightBottom;
  final String userInitialPush;
  final String userMacAddress;
  final String userSerialNumber;
  final String userNotifEvent;
  final String userLastLogin;

  User({
    this.userId,
    this.userName,
    this.userMode,
    this.userPic,
    this.userHeightTop,
    this.userHeightBottom,
    this.userInitialPush,
    this.userMacAddress,
    this.userSerialNumber,
    this.userNotifEvent,
    this.userLastLogin,
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
      KEY_USER_SERIAL: userSerialNumber,
      KEY_USER_NOTIF_EVENT: userNotifEvent,
      KEY_USER_LAST_LOGIN: userLastLogin,
    };
  }
}
