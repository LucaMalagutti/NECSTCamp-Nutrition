import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:login/login.dart';
import 'package:nutrition/OtherMeals.dart';
import 'package:nutrition/ScheduleTab.dart';
import 'package:nutrition/SettingsTab.dart';
import 'package:nutrition/SummaryTab.dart';

class NutritionApp extends StatefulWidget {
  NutritionAppState createState() => new NutritionAppState();
}

class NutritionAppState extends State<NutritionApp> with AuthListener{
  BuildContext _context;
  AuthState auth;

  @override
  void onAuthChanged(bool isLoggedIn) {
    if (_context != null && !isLoggedIn) {
      Navigator.pushAndRemoveUntil(
          _context,
          MaterialPageRoute(
              builder: (context) =>
              // NOTE: we are not passing navigateTo to LoginPage, this way
              //       when the user logs in successfully the LoginPage is
              //       popped from the Navigator stack and we come back to this
              //       page as it was.
              LoginPage(title: "Login", subTitle: "Log back in.", navigateTo: NutritionApp())),
          ModalRoute.withName('/'),
      );
    }
  }

  @override
  void dispose() {
    auth.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Auth.of(context);
    auth.subscribe(this);
    _context = context;
  }

  @override
  Widget build(context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              labelStyle: TextStyle(fontSize: 12.5),
              tabs: [
                Tab(text: "Schedule",icon: Icon(Icons.calendar_today),),
                Tab(text: "Snacks",icon: Icon(Icons.calendar_view_day)),
                Tab(text: "Summary",icon: Icon(Icons.assessment)),
                Tab(text: "Settings",icon: Icon(Icons.settings)),
              ],
            ),
            leading: Icon(Icons.fastfood),
            title: Text("NECST Food"),
          ),
          body: TabBarView(
            children: [
              ScheduleScaffold(),
              OtherMeals(),
              Summary(),
              Settings(),
            ],
          ),
        ),
    );
  }
}


void main() {
  debugPaintSizeEnabled = false;
  runApp(new Auth(
    //url: 'http://10.0.2.2:1378',
    url: "https://api.necstcamp.necst.it",
    child: MaterialApp(
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
      debugShowCheckedModeBanner: false,
      title: 'NECST Food',
      theme: ThemeData(
        // Define the default Brightness and Colors
        brightness: Brightness.light,
        primaryColor: const Color(0xff2E7D32),
        accentColor: Colors.lightGreen,
        // Define the default Font Family
        fontFamily: 'Roboto',
      ),
      home: LoginPage(
        title: "NECST Food",
        subTitle: "Login",
        navigateTo: NutritionApp(),
    ),
    ),
  ));
}
