import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:login/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings extends StatefulWidget {
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  TimeOfDay lunchNotificationTime = TimeOfDay(hour: 14, minute: 17);
  TimeOfDay dinnerNotificationTime = TimeOfDay(hour: 21, minute: 31);

  bool lunchActivated = false;
  bool dinnerActivated = false;

  @override
  void initState() {
    super.initState();
    loadLunchData();
    loadDinnerData();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: onSelectNotification);
    //showScheduled();
  }

  loadLunchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      var lunchMinute = (prefs.getInt('lunchMinute') ?? 17);
      var lunchHour = (prefs.getInt('lunchHour') ?? 13);
      lunchNotificationTime = TimeOfDay(hour: lunchHour, minute: lunchMinute);
      lunchActivated = (prefs.getBool('lunch') ?? false);
    });
  }

  loadDinnerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      var dinnerMinute = (prefs.getInt('dinnerMinute') ?? 31);
      var dinnerHour = (prefs.getInt('dinnerHour') ?? 20);
      dinnerNotificationTime = TimeOfDay(hour: dinnerHour, minute: dinnerMinute);
      dinnerActivated = (prefs.getBool('dinner') ?? false);
    });
  }

  saveLunchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      prefs.setInt('lunchMinute', lunchNotificationTime.minute);
      prefs.setInt('lunchHour', lunchNotificationTime.hour);
      prefs.setBool('lunch', lunchActivated);
    });
  }

  saveDinnerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      prefs.setInt('dinnerMinute', dinnerNotificationTime.minute);
      prefs.setInt('dinnerHour', dinnerNotificationTime.hour);
      prefs.setBool('dinner', dinnerActivated);
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint("payload : $payload");
    }
  }

  showLunchNotification(bool activated) async {
    if (!mounted) return;
    setState(() {
      lunchActivated = activated;
      saveLunchData();
    });
    if (activated){
      print ('Lunch notification scheduled');
      var time = new Time(
          lunchNotificationTime.hour, lunchNotificationTime.minute, 00);
      var android = new AndroidNotificationDetails(
          'channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android, iOS);

      await flutterLocalNotificationsPlugin.showDailyAtTime(
        17, 'Lunch Reminder', 'Remember to register your meal', time, platform,);

      var pendingNotificationRequests = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      print("LISTA NOTIFICHE SCHEDULEATE:$pendingNotificationRequests");
    }
    else {
      print('Lunch notification canceled');
      await flutterLocalNotificationsPlugin.cancel(17);
    }
  }

  showDinnerNotification(bool activated) async {
    if (!mounted) return;
    setState(() {
      dinnerActivated = activated;
      saveDinnerData();
    });
    if(activated) {
      print('Dinner notification scheduled');
      var time = new Time(
          dinnerNotificationTime.hour, dinnerNotificationTime.minute, 00);
      var android = new AndroidNotificationDetails(
          'channel id', 'channel NAME', 'CHANNEL DESCRIPTION');
      var iOS = new IOSNotificationDetails();
      var platform = new NotificationDetails(android, iOS);

      await flutterLocalNotificationsPlugin.showDailyAtTime(
        31, 'Dinner Reminder', 'Remember to register your meal', time,
        platform,);

      var pendingNotificationRequests = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      print(pendingNotificationRequests);
    }
    else {
      print('Dinner notification canceled');
      await flutterLocalNotificationsPlugin.cancel(31);
    }
  }

  Future showPicker(String type) async {
    TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (picked != null && type == 'lunch')
      await flutterLocalNotificationsPlugin.cancel(17).then((value){
        if (!mounted) return;
        setState(() {
          lunchActivated = false;
          lunchNotificationTime = picked;
          saveLunchData();
        });
      });
    if (picked != null && type == 'dinner')
      await flutterLocalNotificationsPlugin.cancel(31).then((value){
        if (!mounted) return;
        setState(() {
          dinnerActivated = false;
          dinnerNotificationTime = picked;
          saveDinnerData();
        });
      });
  }

  notificationReset() async {
    await flutterLocalNotificationsPlugin.cancelAll().then((value){
      print("All notifications canceled");
      if (!mounted) return;
      setState(() {
        lunchActivated = false;
        dinnerActivated = false;
        saveLunchData();
        saveDinnerData();
      });
    });
  }

  showScheduled() async {
    var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print(pendingNotificationRequests);
  }

  String parseMinuteNumber (int minutes){
    if(minutes<10) {
      var stringa = '0' + minutes.toString();
      return stringa;
    }
    return minutes.toString();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12),
                child:  Auth.of(context).isLoggedIn() ? Text("You are logged in as: ${Auth.of(context).user.username}",
                style: TextStyle(fontSize: 19)): Text(""),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Auth.of(context).logout();
                },
                child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: new BoxDecoration(
                      color: Color(0xffe53935),
                      borderRadius: BorderRadius.circular(8),
                      border: new Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text("Log Out",
                            style: TextStyle(fontSize: 15))
                      ],
                    )),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Lunch Notification",
              style: TextStyle(fontSize: 19,)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showPicker('lunch');
                      },
                      icon: Icon(Icons.access_time, size: 30, color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text("@ ${lunchNotificationTime.hour}:${parseMinuteNumber(lunchNotificationTime.minute)}"),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Checkbox(
                      value: lunchActivated,
                      onChanged: showLunchNotification,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text("Scheduled"),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Dinner Notification",
              style: TextStyle(fontSize: 19,)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showPicker('dinner');
                      },
                      icon: Icon(Icons.access_time, size: 30, color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text("@ ${dinnerNotificationTime.hour}:${parseMinuteNumber(dinnerNotificationTime.minute)}"),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    Checkbox(
                      value: dinnerActivated,
                      onChanged: showDinnerNotification,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text("Scheduled"),
                    ),
                  ],
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  notificationReset();
                },
                child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(8),
                    decoration: new BoxDecoration(
                      color: Color(0xffe53935),
                      borderRadius: BorderRadius.circular(8),
                      border: new Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text("Cancel all notifications",
                            style: TextStyle(fontSize: 15))
                      ],
                    )),
              ),
            ],
          )
        ],
      )
    );
  }
}