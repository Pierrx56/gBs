import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gbsalternative/DatabaseHelper.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//helpful tuto: https://www.youtube.com/watch?v=n8-dGz1yNC8&feature=emb_logo

/*
* Classe pour gérer les notifications
* Une fois instanciée, doit impérativement être initialiser avec init(USER)
* */

class NotificationManager {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  DatabaseHelper db;
  MethodChannel platform;
  User user;

  void init(User _user) async{
    user = _user;
    db = new DatabaseHelper();
    tz.initializeTimeZones();
    platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');
    final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);

  }

  Future onSelectNotification(String payload){
    print("payload: $payload");
    /*showDialog(context: context, builder: (_) => new AlertDialog(
      title: new Text("Notification"),
      content: new Text("Payload"),
    ));*/
  }

  showNotification() async {
    var android = new AndroidNotificationDetails("channelId", "channelName", "channelDescription");
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin.show(0, "title", "body", platform, payload: "Bonjour");

  }


  Future<void> setNotificationAlert() async {

    //Mise à jour du dernier lancement de l'appli
    db.updateUser(User(
      userId: user.userId,
      userName: user.userName,
      userMode: user.userMode,
      userPic: user.userPic,
      userHeightTop: user.userHeightTop,
      userHeightBottom: user.userHeightBottom,
      userInitialPush: user.userInitialPush,
      userMacAddress: user.userMacAddress,
      userSerialNumber: user.userSerialNumber,
      userNotifEvent: user.userNotifEvent,
      userLastLogin: tz.TZDateTime.now(tz.local).toString(),
    ));

    await _scheduleNotification();

  }

  Future<void> _scheduleNotification() async {
    var temp = _nextInstanceForNotif();
    if(temp != null)
    await flutterLocalNotificationsPlugin.zonedSchedule(
        user.userId,
        "Daily remind",
        "Hey ${user.userName}, let's train yourself with Spineo Home !",
        temp,
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'Spineo Home daily notification',
              'Notification to remind you to practice Spineo Home'),
          iOS: IOSNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceForNotif() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour, now.minute);

    String day = user.userNotifEvent;

    //Si notifs désactivées
    if(day == "0"){
      cancelNotification();
      return null;
      //return scheduledDate.add(const Duration(days: 730));
    }

    //TODO Update duration for 1 day
    else if (day == "1"){
      //now.add(const Duration(days: 1));
      scheduledDate = scheduledDate.add(const Duration(minutes: 1));
    }
    else if (day == "2") {
      scheduledDate = scheduledDate.add(const Duration(days: 2));
    } else if (day == "3") {
      scheduledDate = scheduledDate.add(const Duration(days: 3));
    }

    print("Scheduled");

    return scheduledDate;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(user.userId);
  }


}
