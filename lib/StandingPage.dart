import 'package:flutter/material.dart';
import 'package:login/login.dart';
import 'package:nutrition/API.dart';
import 'package:nutrition/Utils.dart';

class StandingRoute extends StatefulWidget {
  StandingRoute({Key key}) : super(key: key);
  @override
  StandingRouteState createState() => new StandingRouteState();
}

class StandingRouteState extends State<StandingRoute> {
  API api = new API();
  List<dynamic> standing;
  String titleString = '';

  double getFontSize (index) {
    if (index == 1) {
      return 27.0;
    }
    if (index == 2) {
      return 24.0;
    }
    if (index == 3) {
      return 21.0;
    }
    return 19.0;
  }

  Color highlightUserScore (String username) {
    if (username == Auth.of(context).user.username) {
      return Theme.of(context).accentColor;
    }
    else {
      return Colors.black;
    }
  }

  Color getFontColor(int index, String username) {
//    if (username == Auth.of(context).user.username) {
//      return Colors.redAccent;
//    }
    if (index == 1) {
      return Colors.yellow[800];
    }
    if (index == 2) {
      return Colors.blueGrey[500];
    }
    if (index == 3) {
      return Colors.brown[500];
    }
    return Colors.black;
  }

  String createTitleString(DateTime now) {
    int weekNumber = Utils.getWeekNumber(now);
    if (weekNumber == 22 || weekNumber == 21) {
      return "NGC Standing";
    }
    return "Week "+weekNumber.toString()+" Standing";
  }

  String parseScore(score) {
    return score.toStringAsFixed(0);
  }

  @override
  void initState() {
    super.initState();
    setState((){
      titleString = createTitleString(DateTime.now());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffd9dde2),
        appBar: AppBar(
          title: Text("Standing"),
        ),
        body: Container(
                margin: EdgeInsets.only(left: 12, top: 16, right: 12, bottom: 12),
                padding: EdgeInsets.all(8),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  //border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                      child: Center(
                      child: Text("$titleString",style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    FutureBuilder<List>(
                        future: api.getStanding(Utils.getWeekNumber(DateTime.now()), DateTime.now().toUtc().toString(), context),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return new Text('Loading....');
                            default:
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              else
                                standing = snapshot.data;
                                return Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: GridView.count(
                                          crossAxisCount: 1,
                                          childAspectRatio: 5.4,
                                          children: List.generate(standing.length, (index) {
                                          return Container(
                                            padding: EdgeInsets.only(top: 8, right: 8, left: 8, bottom: 2),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 1.5, color: Color(0xff2E7D32)),
                                              ),
                                            ),
                                            child:
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    Container(width: 30, child: Center(child: Text("${index+1}.",style: TextStyle(color: getFontColor(index+1, standing[index][1]), fontSize: getFontSize(index+1), fontWeight: FontWeight.w500)))),
                                                    Container(width: 200,child: Center(child: Text("${standing[index][1]}", style: TextStyle(fontSize: 16)))),
                                                    Container(width: 60, child: Center(child: Text("${parseScore(standing[index][0])}", style: TextStyle(color: highlightUserScore(standing[index][1]), fontSize: 17, fontWeight: FontWeight.w500),))),
                                                  ],
                                                ),
                                          );}))
                                      ),
                                    ],
                                  ),
                                );
                          }
                        }),
                  ],
                )));
  }
}
