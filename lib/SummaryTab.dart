import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nutrition/API.dart';
import 'package:nutrition/Meal.dart';
import 'package:nutrition/StandingPage.dart';
import 'package:nutrition/Utils.dart';
import 'package:nutrition/WeekSummary.dart';

class Summary extends StatefulWidget {
  SummaryState createState() => new SummaryState();
}

class SummaryState extends State<Summary> {
  API api = new API();
  bool firstTime = true;

  static DateTime _dateValue = DateTime.now();
  String _endDate = DateFormat("y-MM-d 23:59:59").format(_dateValue);
  String _startDate = DateFormat("y-MM-d 00:00:00").format(Utils.getPreviousMonday(_dateValue));

  List<Meal> completeMealList;
  List<Meal> mealList;
  int correctMeals = 0;
  int mealCount = 0;
  List<String> proteinSchedule = ["", "", "", "", "", "", "", "", "", "", "", "", "", ""];
  List<List<String>> mealsProteins = [[], [], [], [], [], [], [], [], [], [], [], [], [], []];
  WeekSummary thisWeekSummary = WeekSummary(0, 0, 0.0,0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0,0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0);
  Map<String, int> proteinCounts = {"white_meat": 0, "red_meat": 0, "fish": 0, "legumes": 0, "cheese": 0, "eggs": 0};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime==true) {
      firstTime = false;
      api.getMealsEaten(_startDate, _endDate, context).then((res1) {
        api.getWeekSchedule(Utils.getWeekNumber(DateTime.now()), DateTime
            .now()
            .year, context).then((res2) {
          if (!mounted) return;
          setState(() {
            completeMealList = Utils.createCompleteMealsList(res1);
            mealList = Utils.createMealsList(res1);
            mealCount = mealList.length;
            mealsProteins = Utils.createProteinsList(mealList, mealsProteins);
            proteinSchedule = Utils.createProteinSchedule(res2[0]);
            correctMeals =
                Utils.getCorrectMeals(mealsProteins, proteinSchedule);
            proteinCounts = Utils.createProteinCounts(res2[1], proteinCounts);
          });
          api.getWeekSummary(Utils.getWeekNumber(DateTime.now()), DateTime
              .now()
              .year, context).then((res3) {
            if (res3.year != -1) {
              if (!mounted) return;
              setState(() {
                thisWeekSummary = res3;
              });
            }
          });
        });
      });
    }
  }

  Color getExtraColor(int extra) {
    if (extra > 3) return Colors.red;
    else if (extra == 3) return Colors.orange;
    else return Colors.black;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffd9dde2),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16, right: 8, left: 8, bottom: 0),
                child: Text(
                    "Week ${Utils.getWeekNumber(DateTime.now())} Summary",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                padding: EdgeInsets.all(8),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text("Correct Meals", textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Center(
                                child: Text("$correctMeals / $mealCount", textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(child: Text("Extra", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: getExtraColor(thisWeekSummary.totalExtra)))),
                              Center(child: Text("${thisWeekSummary.totalExtra}", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: getExtraColor(thisWeekSummary.totalExtra)))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text("Weekly Score", textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Center(
                                child: Text("${thisWeekSummary.score}", textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 12, right: 12, left: 12, bottom: 16),
                padding: EdgeInsets.all(8),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(child: Text("Portions left", style: TextStyle(fontSize: 19))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text("White Meat ${proteinCounts["white_meat"]}", style: TextStyle(fontSize: 16)),
                              Text("Red Meat ${proteinCounts["red_meat"]}", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text("Fish ${proteinCounts["fish"]}", style: TextStyle(fontSize: 16)),
                              Text("Legumes ${proteinCounts["legumes"]}", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text("Cheese ${proteinCounts["cheese"]}", style: TextStyle(fontSize: 16)),
                              Text("Eggs ${proteinCounts["eggs"]}", style: TextStyle(fontSize: 16))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("Proteins",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/white_meat.png",
                        counter: thisWeekSummary.whiteMeatCount,
                        text: "White Meat"),
                    MyTile(
                        imageUrl: "Icons/red_meat.png",
                        counter: thisWeekSummary.redMeatCount,
                        text: "Red Meat"),
                    MyTile(
                        imageUrl: "Icons/fish.png",
                        counter: thisWeekSummary.fishCount,
                        text: "Fish"),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/legumes.png",
                        counter: thisWeekSummary.legumesCount,
                        text: "Legumes"),
                    MyTile(
                        imageUrl: "Icons/cheese.png",
                        counter: thisWeekSummary.cheeseCount,
                        text: "Cheese"),
                    MyTile(
                        imageUrl: "Icons/eggs.png",
                        counter: thisWeekSummary.eggsCount,
                        text: "Eggs"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("Liquids",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/water.png",
                        counter: thisWeekSummary.waterCount.round(),
                        text: "Water"),
                    MyTile(
                        imageUrl: "Icons/soda.png",
                        counter: thisWeekSummary.sodaCount.round(),
                        text: "Soda"),
                    MyTile(
                        imageUrl: "Icons/alcohol.png",
                        counter: thisWeekSummary.alcoholCount.round(),
                        text: "Alcohol"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Other',
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/vegetables.png",
                        counter: thisWeekSummary.vegetablesCount,
                        text: "Vegetables"),
                    MyTile(
                        imageUrl: "Icons/fruits.png",
                        counter: thisWeekSummary.fruitsCount,
                        text: "Fruits"),
                    MyTile(
                        imageUrl: "Icons/carbs.png",
                        counter: thisWeekSummary.carbsCount,
                        text: "Carbs"),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/coffee.png",
                        counter: thisWeekSummary.coffeeCount,
                        text: "Coffee"),
                    MyTile(
                        imageUrl: "Icons/sweets.png",
                        counter: thisWeekSummary.sweetsCount,
                        text: "Sweets"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Extra', style: TextStyle(fontSize: 18)),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyTile(
                        imageUrl: "Icons/bigCake.png",
                        counter: thisWeekSummary.sweetExtraCount,
                        text: "Sweet Extra"),
                    MyTile(
                        imageUrl: "Icons/fried.png",
                        counter: thisWeekSummary.friedCount,
                        text: "Fried"),
                    MyTile(
                        imageUrl: "Icons/quantity.png",
                        counter: thisWeekSummary.quantityCount,
                        text: "Quantity"),
                  ],
                ),
              ),
              Container(
                height: 50,
              )
            ],
          ),
        )
    , floatingActionButton: FloatingActionButton(
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  StandingRoute()),
            ).then((value) {
              if (value == 1) {
                print("PICCIONE");
              }
            });
          },
        child: Icon(Icons.timeline)),
    );
  }
}

class MyTile extends StatefulWidget {
  final String text;
  final int counter;
  final String imageUrl;
  MyTile({Key key, this.imageUrl, this.counter, this.text}) : super(key: key);

  @override
  MyTileState createState() => new MyTileState();
}

class MyTileState extends State<MyTile> {

  Color getTileColor(text, counter) {
    if((text == "Soda" && counter == 7) || (text == "Alcohol" && counter == 3) || (text == "Coffee" && counter == 21)) {
      return Colors.orange;
    }
    if((text == "Soda" && counter > 7) || (text == "Alcohol" && counter > 3) || (text == "Coffee" && counter > 21)) {
      return Colors.red;
    }
    return Color(0xff2E7D32);
  }

  Widget build(BuildContext context) {
    return Container(
        width: 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 6.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                -1.0, // horizontal, move right 10
                3.0, // vertical, move down 10
              ),
            )
          ],
          color: getTileColor(widget.text, widget.counter),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(widget.text, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset(widget.imageUrl, scale: 1.2),
                      Text(widget.counter.toString(),
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ],
                  ),
                )
              ],
            )));
  }
}
