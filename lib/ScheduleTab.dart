import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:login/login.dart';
import 'package:nutrition/API.dart';
import 'package:nutrition/WeekSummary.dart';

import 'EditDeleteMealPage.dart';
import 'Meal.dart';
import 'NewMealPage.dart';
import 'Utils.dart';

class ScheduleScaffold extends StatefulWidget {
  ScheduleScaffold({Key key}) : super(key: key);
  @override
  ScheduleScaffoldState createState() => new ScheduleScaffoldState();
}

class ScheduleScaffoldState extends State<ScheduleScaffold> {
  API api = new API();
  bool firstTime = false;

  static DateTime _dateValue = DateTime.now();
  String _endDate = DateFormat("y-MM-d 23:59:59").format(_dateValue);
  String _startDate = DateFormat("y-MM-d 00:00:00").format(Utils.getPreviousMonday(_dateValue));


  final Meal noneMeal = Meal(meal_id: 0, date: "00-00-00 00:00:00", type: "None", snack_id: -1, white_meat: 0, red_meat: 0, fish: 0, legumes: 0, cheese: 0, eggs: 0, water_drunk: 0.0, soda_drunk: 0.0, alcohol_drunk: 0.0, vegetables: 0, fruits: 0, carbs: 0, coffee: 0, sweets: 0, fried: 0,quantity: 0,extra_protein: 0, sweet_extra: 0, image: "noImageTaken", image2: "noImageTaken", score: 0, notes: "");
  bool _isAddButtonDisabled = true;

  List<List<String>> mealsProteins = [[], [], [], [], [], [], [], [], [], [], [], [], [], []];
  WeekSummary thisWeekSummary = WeekSummary(0, 0, 0.0,0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  List<Meal> completeMealList;
  List<Meal> mealList = [];
  List<Meal> mealsEaten = [];
  List<String> proteinSchedule = ["", "", "", "", "", "", "", "", "", "", "", "", "", ""];
  List<String> proteins = ["white_meat","red_meat","fish","legumes","cheese","eggs"];
  Map<String, int> proteinCounts = {"white_meat": 0, "red_meat": 0, "fish": 0, "legumes": 0, "cheese": 0, "eggs": 0};
  Map<String, int> prescription = {"white_meat": 0, "red_meat": 0, "fish": 0, "legumes": 0, "cheese": 0, "eggs": 0};

  int mealCount = 0;
  int correctMeals = 0;

  Color getContainerColor(schedule, mealsProteins, mealsEaten, counts, index) {
    if (mealsProteins[index].length == 0 && mealsEaten[index].date == "00-00-00 00:00:00") {
      return Colors.blueGrey;
    }

    if (!mealsProteins[index].contains(schedule[index])) {
      return Color(0xffd12b2b);
    } else {
      return Color(0xff388E3C);
    }
  }

  Icon getMealIcon(schedule, mealsProteins, mealsEaten, counts, index) {
//    for(var a=0; a<mealsProteins[index].length; a++) {
//      if (proteinCounts[mealsProteins[index][a]] < 0) {
//        var counter = 0;
//        for (var b = 0; b <= index; b++) {
//          if (mealsEaten[b].toJsonMeal()[proteins[proteins.indexOf(
//              mealsProteins[index][a])]] == 1) {
//            counter++;
//            if (counter > prescription[schedule[index]]) {
//              return Icon(Icons.clear, size: 40);
//            }
//          }
//        }
//      }
//    }

    if (mealsProteins[index].contains(schedule[index])) {
      return Icon(Icons.done, size: 40);
    } else
      return Icon(Icons.clear, size: 40);
  }

  String getMealName(schedule, eatenList, meal) {
    if (meal.date == "00-00-00 00:00:00" || eatenList.contains(schedule)) {
      return "";
    } else if (eatenList.length == 0) {
      return "No protein eaten";
    } else
      return Utils.parseDBString(eatenList[0]);
  }

  String getWeekDate(DateTime today, int index) {
    DateTime previousMonday = Utils.getPreviousMonday(today);
    DateTime date = previousMonday.add(new Duration(days: (index / 2).floor()));
    return DateFormat("EEEE, d MMM").format(date);
  }

  @override
  void initState() {
    super.initState();
    firstTime = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(Auth.of(context).isLoggedIn() && firstTime) {
      firstTime = false;
      for (var i = 0; i < 14; i++) {
        mealsEaten.add(noneMeal);
      }
      api.getWeekSchedule(Utils.getWeekNumber(_dateValue), _dateValue.year, context).then((res1) {
        api.getMealsEaten(_startDate, _endDate, context).then((res2) {
          if (!mounted) return;
            setState(() {
              proteinSchedule = Utils.createProteinSchedule(res1[0]);
              proteinCounts = Utils.createProteinCounts(res1[1], proteinCounts);
              mealList = Utils.createMealsList(res2);
              mealsProteins = Utils.createProteinsList(mealList, mealsProteins);
              mealsEaten = Utils.createMealsEaten(mealList, mealsEaten);
              prescription = Utils.createPrescription(prescription, proteinCounts, mealList);
              _isAddButtonDisabled = false;
            });
        });
      });
    }
  }

  void afterMealChange() {
    setState(() {
      mealsProteins =
      [[], [], [], [], [], [], [], [], [], [], [], [], [], []];
      //mealList = [];
      for (var i = 0; i < 14; i++) {
        mealsEaten[i] = noneMeal;
      }
    });
    api.getMealsEaten(_startDate, _endDate, context).then((res1) {
      if (!mounted) return;
      setState(() {
        completeMealList = Utils.createCompleteMealsList(res1);
        mealList = Utils.createMealsList(res1);
        mealCount = mealList.length;
        mealsProteins = Utils.createProteinsList(mealList, mealsProteins);
        mealsEaten = Utils.createMealsEaten(mealList, mealsEaten);
      });
      api.updateSchedule(Utils.getWeekNumber(_dateValue), _dateValue.year, Utils.convertMealsEatenToJson(mealsEaten), proteinSchedule, context).then((res2) {
        if (!mounted) return;
        setState((){
          proteinSchedule = Utils.createProteinSchedule(res2[0]);
          proteinCounts = Utils.createProteinCounts(res2[1], proteinCounts);
          correctMeals =
              Utils.getCorrectMeals(mealsProteins, proteinSchedule);
        });
        thisWeekSummary = Utils.updateSummaryValues(
            completeMealList, (mealCount - correctMeals), DateTime.now(), proteinCounts);
        api.updateWeekSummary(thisWeekSummary, context).then((res3) {
          if (res3 == 200) {
            if (!mounted) return;
            setState(() {
              thisWeekSummary = thisWeekSummary;
            });
          }
          api.updateStanding(DateTime.now().toUtc().toString(), Utils.getWeekNumber(DateTime.now()), thisWeekSummary.score, context);
        });
      });
    });
  }

  void openMealPage(int tileIndex, Meal editMeal, List<Meal> listMeal) {
    if (editMeal.meal_id != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new EditDeleteMealRoute(editMeal: editMeal, mealsList: listMeal, isSnack: false)),
      ).then((value) {
        if(value == 1) {
          if (!mounted) return;
          afterMealChange();
        }
      });
    }
    else {
      if(_isAddButtonDisabled) {
        Utils.showAlert("Connection problem", "Check your internet connection, or ask the admin to initialize your account", context);
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              NewMealRoute(tileIndex: tileIndex, mealsList: mealList, isSnack: false)),
        ).then((value) {
          if (value == 1) {
            afterMealChange();
          }
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,//const Color(0xffd9dde2),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text('Lunch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Text('Dinner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2 ,
              childAspectRatio: 1.8,
              children: List.generate(14, (index) {
                return InkWell(
                  onTap: () {
                    openMealPage(index, mealsEaten[index], mealList);
                  },
                  child: Container(
                    margin: EdgeInsets.all(6),
                    padding: EdgeInsets.all(8),
                    decoration: new BoxDecoration(
                      color: getContainerColor(proteinSchedule,
                          mealsProteins, mealsEaten, proteinCounts, index),
                      borderRadius: BorderRadius.circular(6),
                      border: new Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(getWeekDate(DateTime.now(), index),
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        Utils.parseDBString(
                                            proteinSchedule[index]),
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white)),
                                    Text(
                                        getMealName(
                                            proteinSchedule[index],
                                            mealsProteins[index],
                                            mealsEaten[index]),
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    (mealsProteins[index].length == 0 &&
                                        mealsEaten[index].date ==
                                            "00-00-00 00:00:00")
                                        ? Text('')
                                        : getMealIcon(proteinSchedule,
                                        mealsProteins, mealsEaten, proteinCounts, index)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_isAddButtonDisabled) {
              Utils.showAlert("Connection problem", "Check your internet connection, or ask the admin to initialize your account", context);
            }
            else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    NewMealRoute(tileIndex: null, mealsList: mealList, isSnack: false)),
              ).then((value) {
                if (value == 1) {
                  afterMealChange();
                }
              });
            }
          },
          child: Icon(Icons.add)),
    );
  }
}
