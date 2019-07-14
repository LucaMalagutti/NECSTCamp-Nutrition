import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrition/API.dart';
import 'package:nutrition/EditDeleteMealPage.dart';
import 'package:nutrition/Meal.dart';
import 'package:nutrition/NewMealPage.dart';
import 'package:nutrition/Utils.dart';
import 'package:nutrition/WeekSummary.dart';

class OtherMeals extends StatefulWidget {
  OtherMealsState createState() => new OtherMealsState();
}

class OtherMealsState extends State<OtherMeals> {
  API api = new API();
  bool _isAddButtonDisabled = true;

  static DateTime _dateValue = DateTime.now();
  String _endDate = DateFormat("y-MM-d 23:59:59").format(_dateValue);
  String _startDate =
      DateFormat("y-MM-d 00:00:00").format(Utils.getPreviousMonday(_dateValue));

  final Meal noneMeal = Meal(meal_id: 0, date: "00-00-00 00:00:00", type: "None", snack_id: -1, white_meat: 0, red_meat: 0, fish: 0, legumes: 0, cheese: 0, eggs: 0, water_drunk: 0.0, soda_drunk: 0.0, alcohol_drunk: 0.0, vegetables: 0, fruits: 0, carbs: 0, coffee: 0, sweets: 0, fried: 0,quantity: 0,extra_protein: 0, sweet_extra: 0, image: "noImageTaken", image2: "noImageTaken", score: 0, notes: "");
  List<Meal> snacksList;
  WeekSummary thisWeekSummary = WeekSummary(0, 0, 0.0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  List<List<String>> mealsProteins = [[], [], [], [], [], [], [], [], [], [], [], [], [], []];
  List<Meal> completeMealList;
  List<Meal> mealList = [];
  List<Meal> mealsEaten = [];
  List<String> proteinSchedule = ["", "", "", "", "", "", "", "", "", "", "", "", "", ""];
  List<String> proteins = ["white_meat","red_meat","fish","legumes","cheese","eggs"];
  Map<String, int> proteinCounts = {"white_meat": 0, "red_meat": 0, "fish": 0, "legumes": 0, "cheese": 0, "eggs": 0};
  Map<String, int> prescription = {"white_meat": 0, "red_meat": 0, "fish": 0, "legumes": 0, "cheese": 0, "eggs": 0};

  int mealCount = 0;
  int correctMeals = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 14; i++) {
      mealsEaten.add(noneMeal);
    }
  }

  void openEditMealPage(Meal editMeal, List<Meal> listMeal) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
          new EditDeleteMealRoute(editMeal: editMeal, mealsList: listMeal, isSnack: true)),
    ).then((value) {
      if(value == 1) {
        if (!mounted) return;
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
          api.getWeekSchedule(Utils.getWeekNumber(_dateValue), _dateValue.year, context).then((res2) {
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
              if(res3 == 200) {
                setState(() {
                  thisWeekSummary = thisWeekSummary;
                });
                api.updateStanding(DateTime.now().toUtc().toString(),
                    Utils.getWeekNumber(DateTime.now()), thisWeekSummary.score,
                    context);
              }
            });
          });
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(top: 16, right: 8, left: 8, bottom: 8),
            child: Center(
              child: Text("Breakfasts & Snacks",style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600)),
            )
        ),
        FutureBuilder<List>(
          future:
              api.getMealsEaten(_startDate, _endDate, context), // async work
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading....');
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else
                  _isAddButtonDisabled = false;
                  snacksList =
                      Utils.createSnacksList(snapshot.data);
                  completeMealList = Utils.createCompleteMealsList(snapshot.data);
                return Expanded(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: GridView.count(
                            crossAxisCount: 1,
                            childAspectRatio: 5.4,
                            children:
                                List.generate(snacksList.length, (index) {
                                  return Container(
                                          margin: EdgeInsets.all(6),
                                          padding: EdgeInsets.all(8),
                                          decoration: new BoxDecoration(
                                            color: Colors.blueGrey,
                                            borderRadius: BorderRadius.circular(6),
                                            border: new Border.all(color: Colors.black, width: 2),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text("${DateFormat("EEEE, d MMM").format(DateTime.parse(snacksList[index].date))} - ${Utils.parseDBMealTypeString(snacksList[index].type)}",style: TextStyle(
                                                  fontSize: 17, color: Colors.white)),
                                              IconButton(
                                                onPressed: () {openEditMealPage(snacksList[index], snacksList);},
                                                color: Colors.white,
                                                icon: Icon(Icons.edit),
                                                iconSize: 30,
                                              )
                                            ],
                                          ));
                                })),
                      ),
                    ],
                  ),
                );
            }
          },
        )
      ],
    ),
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
        onPressed: (){
          if (_isAddButtonDisabled) {
            Utils.showAlert("Connection problem", "Check your internet connection and try again", context);
          }
          else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  NewMealRoute(mealsList: snacksList, isSnack: true)),
            ).then((value) {
              if(value == 1) {
                if (!mounted) return;
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
                  api.getWeekSchedule(Utils.getWeekNumber(_dateValue), _dateValue.year, context).then((res2) {
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
                        api.updateStanding(DateTime.now().toUtc().toString(), Utils.getWeekNumber(DateTime.now()), thisWeekSummary.score, context);
                      }
                    });
                  });
                });
              }
            });
          }
        }),
    );
  }
}
