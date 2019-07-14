import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login/login.dart';
import 'package:nutrition/main.dart';
import "WeekSummary.dart";
import "Meal.dart";

class Utils{
  static int calculateSnackNumber(List<Meal> mealList, Meal thisMeal) {
    if (thisMeal.type != "snack") {
      return -1;
    }
    else {
      var maxId = 0;
      for (var i=0; i<mealList.length; i++) {
        if (thisMeal.date.split(' ')[0] == mealList[i].date.split(' ')[0] && mealList[i].type == 'snack' && mealList[i].snack_id > maxId) {
          maxId = mealList[i].snack_id;
        }
      }
      return maxId+1;
    }
  }

  static List<dynamic> createStanding(Map<dynamic, dynamic> getStandingRes) {
    var standing = [];
    getStandingRes.forEach((k,v) {
      var arr = [];
      arr.add(v);
      arr.add(k);
      standing.add(arr);
    });
    return standing;
  }


  static void onUserNotAuthenticated(BuildContext context) {
    TokenExpiredDialog.showUploadDialog(context,
        loginPage: LoginPage(
          title: "NECST Food",
          subTitle: "Log back in.",
          accentColor: Colors.lightGreen,
          navigateTo: NutritionApp(),
        ), onLogout: () {
          // reset data
        });
  }
  static WeekSummary calculateWeekScore(WeekSummary thisWeekSummary, Map<String, int> proteinCounts) {
    if (thisWeekSummary.coffeeCount > 21) {
      thisWeekSummary.score -= 50*(thisWeekSummary.coffeeCount - 21);
    }
    if (thisWeekSummary.sodaCount > 7) {
      thisWeekSummary.score -= 50*(thisWeekSummary.sodaCount - 7);
    }
    if (thisWeekSummary.alcoholCount > 3) {
      thisWeekSummary.score -= 50*(thisWeekSummary.alcoholCount - 3);
    }
    if (thisWeekSummary.totalExtra > 3) {
      thisWeekSummary.score -= 50*(thisWeekSummary.totalExtra-3);
    }
    proteinCounts.forEach((key, value) {
      if (value < 0 && (key=='eggs' || key=='white_meat' || key=='red_meat')) {
        thisWeekSummary.score += 50*(value);
      }
    });
    return thisWeekSummary;
  }

  static double calculateMealScore(Meal myMeal) {
    double score = 0.0;
    if(myMeal.type == 'lunch' || myMeal.type == 'dinner') {
      if (myMeal.white_meat + myMeal.red_meat + myMeal.fish + myMeal.cheese + myMeal.legumes + myMeal.eggs == 1) {
        score += 30;
      }
      if (myMeal.white_meat + myMeal.red_meat + myMeal.fish + myMeal.cheese + myMeal.legumes + myMeal.eggs == 0) {
        score -= 10;
      }
      if (myMeal.water_drunk != 0.0){
        if (myMeal.water_drunk <= 3) {
          score += 10 * (-1 * pow(myMeal.water_drunk, 2) + 2 * myMeal.water_drunk);
        }
        else {
          score -= 10;
        }
      }
      if (myMeal.soda_drunk != 0) {
        score -= 5*myMeal.soda_drunk;
      }
      if (myMeal.alcohol_drunk !=0) {
        score -= 20*myMeal.alcohol_drunk;
      }
      if (myMeal.vegetables == 1) {
        score += 20;
      }
      if (myMeal.fruits == 1) {
        score += 20;
      }
      if (myMeal.carbs == 1) {
        score += 30;
      }
      if (myMeal.vegetables == 0 && myMeal.fruits == 0) {
        score -= 20;
      }
      if (myMeal.sweet_extra == 1) {
        score -= 20;
      }
      if (myMeal.fried == 1) {
        score -= 20;
      }
      if (myMeal.quantity == 1) {
        score -= 20;
      }
      if (myMeal.extra_protein == 1) {
        score -= 10;
      }
    }
    if (myMeal.type == 'breakfast' || myMeal.type == 'snack') {
      if (myMeal.white_meat + myMeal.red_meat + myMeal.fish + myMeal.cheese + myMeal.legumes + myMeal.eggs == 1) {
        score += 10;
      }
      if (myMeal.water_drunk != 0.0){
        if (myMeal.water_drunk <= 3) {
          score += 5 * (-1 * pow(myMeal.water_drunk, 2) + 2 * myMeal.water_drunk);
        }
        else {
          score -= 5;
        }
      }
      if (myMeal.soda_drunk != 0) {
        score -= 2.5*myMeal.soda_drunk;
      }
      if (myMeal.alcohol_drunk !=0) {
        score -= 10*myMeal.alcohol_drunk;
      }
      if (myMeal.vegetables == 1) {
        score += 5;
      }
      if (myMeal.fruits == 1) {
        score += 5;
      }
      if (myMeal.carbs == 1) {
        score += 5;
      }
      if (myMeal.vegetables == 0 && myMeal.fruits == 0) {
        score -= 5;
      }
      if (myMeal.sweet_extra == 1) {
        score -= 10;
      }
      if (myMeal.fried == 1) {
        score -= 10;
      }
      if (myMeal.quantity == 1) {
        score -= 10;
      }
      if (myMeal.extra_protein == 1) {
        score -= 10;
      }
//      if (myMeal.type == 'snack' && myMeal.coffee == 1) {
//        score -= 5;
//      }
    }
    if (score<-200) {
      score = -200.0;
    }
    return num.parse(score.toStringAsFixed(1));
  }

  static void showAlert(String title, String subtitle, BuildContext cont) {
    showDialog(
      context: cont,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(subtitle),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Undo"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static int boolToInt(bool value) {
    if (value)
      return 1;
    else
      return 0;
  }

  static bool intToBool(int value) {
    if (value != 0)
      return true;
    else
      return false;
  }

  static String parseDBString(String DBString) {
    if (DBString == "white_meat") {
      return "White Meat";
    } else if (DBString == "red_meat") {
      return "Red Meat";
    } else if (DBString == "legumes") {
      return "Legumes";
    } else if (DBString == "fish") {
      return "Fish";
    } else if (DBString == "cheese") {
      return "Cheese";
    } else if (DBString == "eggs") {
      return "Eggs";
    } else {
      return "Not Ready";
    }
  }

  static String parseDBMealTypeString(String mealString) {
    if(mealString == 'lunch') return "Lunch";
    else if(mealString == 'dinner') return 'Dinner';
    else if(mealString == 'breakfast') return 'Breakfast';
    else if(mealString == 'snack') return 'Snack';
    else return "NOT A MEAL TYPE";
  }

  static DateTime getPreviousMonday (DateTime today) {
    return today.subtract(new Duration(days: (today.weekday-1)));
  }

  static int mealTypeToInt(String mealType) {
    if (mealType == "lunch") {
      return 2;
    }
    else if (mealType == "dinner") {
      return 3;
    }
    else if (mealType == "breakfast") {
      return 0;
    }
    else return 1;
  }

  static int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  static int getMealIndex(int weekday, String mealType) {
    if (mealType == "dinner")
      return (weekday - 1) * 2 + 1;
    else if (mealType == 'lunch') {
      return (weekday - 1) * 2;
    }
    else return -1;
  }

  static List<Meal> createCompleteMealsList(List<dynamic> getMealsRes) {
    List<Meal> mealList = [];
    for(var i = 0; i<getMealsRes.length; i++) {
      mealList.add(Meal.fromJson(getMealsRes[i]));
      //print(mealList[i].date);
    }
    return mealList;
  }

  static List<Meal> createMealsList(List<dynamic> getMealsRes) {
    List<Meal> mealList = [];
    for(var i = 0; i<getMealsRes.length; i++) {
      var convertedMeal = Meal.fromJson(getMealsRes[i]);
      if(convertedMeal.type == "lunch" || convertedMeal.type == "dinner") {
        mealList.add(convertedMeal);
      }
    }
    return mealList;
  }

  static List<Meal> createSnacksList(List<dynamic> getMealsRes) {
    List<Meal> mealList = [];
    for(var i = 0; i<getMealsRes.length; i++) {
      var convertedMeal = Meal.fromJson(getMealsRes[i]);
      if(convertedMeal.type == "breakfast" || convertedMeal.type == "snack") {
        mealList.add(convertedMeal);
      }
    }
    //reorders snacks by decreasing date
    return Utils.snackBubbleSort(mealList).reversed.toList();
  }

  static List<Meal> snackBubbleSort(List<Meal> list) {
    var retList = new List<Meal>.from(list);
    var tmp;
    var swapped = false;
    do {
      swapped = false;
      for(var i = 1; i < retList.length; i++) {
        if(DateTime.parse(retList[i - 1].date).isAfter(DateTime.parse(retList[i].date)) ) {
          tmp = retList[i - 1];
          retList[i - 1] = retList[i];
          retList[i] = tmp;
          swapped = true;
        }
      }
    } while(swapped);

    return retList;
  }

  static List<String> createProteinSchedule(List<dynamic> res) {
    List<String> schedule = [];
    for(var i = 0; i<res.length; i++) {
      schedule.add(res[i].toString());
    }
    return schedule;
  }

  static Map<String, int> createProteinCounts(List<dynamic> res, Map <String, int> counts ) {
    int counter = 0;
    counts.forEach((key, value) {
      counts[key] = res[counter];
      counter++;
    });
    return counts;
  }

  static List<Meal> createMealsEaten(List<Meal> mealList, List<Meal> mealsEaten) {
    for(var i = 0; i<mealList.length; i++) {
      if(mealList[i].type == "lunch" || mealList[i].type == "dinner") {
        mealsEaten[Utils.getMealIndex(DateTime
            .parse(mealList[i].date)
            .weekday, mealList[i].type)] = mealList[i];
      }
    }
    return mealsEaten;
  }
  static List<List<String>> createProteinsList(List<Meal> mealList, List<List<String>> proteinList) {
    for(var i = 0; i<mealList.length; i++) {
      List<String> proteins = [];

      var index = Utils.getMealIndex(DateTime.parse(mealList[i].date).weekday, mealList[i].type);
      if (mealList[i].white_meat == 1) proteins.add("white_meat");
      if (mealList[i].red_meat == 1) proteins.add("red_meat");
      if (mealList[i].fish == 1) proteins.add("fish");
      if (mealList[i].legumes == 1) proteins.add("legumes");
      if (mealList[i].cheese == 1) proteins.add("cheese");
      if (mealList[i].eggs == 1) proteins.add("eggs");
      proteinList[index] = proteins;
    }
    return proteinList;
  }

  static List<dynamic> convertMealsEatenToJson(List<Meal> mealsEaten) {
    var temp = [];
    for(var i=0; i<mealsEaten.length; i++) {
      temp.add(mealsEaten[i].toJsonMeal());
    }
    return temp;
  }

  static WeekSummary updateSummaryValues(List<Meal> completeMealList, int scheduleChanges, DateTime now, Map<String, int> proteinCounts) {
    WeekSummary lastSummary = WeekSummary(now.year,Utils.getWeekNumber(now),0.0,0,0,0,0,0,0,0.0,0.0,0.0,0,0,0,0,0,0,0,0,0,0,0);
    for (var i=0; i<completeMealList.length; i++) {
      lastSummary.whiteMeatCount += completeMealList[i].white_meat;
      lastSummary.redMeatCount += completeMealList[i].red_meat;
      lastSummary.fishCount += completeMealList[i].fish;
      lastSummary.legumesCount += completeMealList[i].legumes;
      lastSummary.cheeseCount += completeMealList[i].cheese;
      lastSummary.eggsCount += completeMealList[i].eggs;
      lastSummary.waterCount += completeMealList[i].water_drunk;
      lastSummary.sodaCount += completeMealList[i].soda_drunk;
      lastSummary.alcoholCount += completeMealList[i].alcohol_drunk;
      lastSummary.carbsCount += completeMealList[i].carbs;
      lastSummary.vegetablesCount += completeMealList[i].vegetables;
      lastSummary.fruitsCount += completeMealList[i].fruits;
      lastSummary.coffeeCount += completeMealList[i].coffee;
      lastSummary.sweetsCount += completeMealList[i].sweets;
      lastSummary.friedCount += completeMealList[i].fried;
      lastSummary.quantityCount += completeMealList[i].quantity;
      lastSummary.extraProteinCount += completeMealList[i].extra_protein;
      lastSummary.sweetExtraCount += completeMealList[i].sweet_extra;
      lastSummary.score += completeMealList[i].score;
      lastSummary.totalExtra += Utils.calculateExtra(completeMealList[i].sweet_extra, completeMealList[i].fried, completeMealList[i].quantity, completeMealList[i].extra_protein);
    }

    lastSummary.scheduleChanges = scheduleChanges;
    lastSummary = Utils.calculateWeekScore(lastSummary, proteinCounts);

    //print(lastSummary.totalExtra);

    return lastSummary;
  }

  static int calculateExtra(sweetExtra, fried, quantity, extraProtein) {
    if (sweetExtra+fried+quantity+extraProtein > 0) {
      return 1;
    }
    else return 0;
  }

  static Map<String, int> createPrescription(Map<String, int> prescription, Map<String, int> counts, List<Meal> completeMealsList) {
    prescription["white_meat"] = counts["white_meat"];
    prescription["red_meat"] = counts["red_meat"];
    prescription["fish"] = counts["fish"];
    prescription["legumes"] = counts["legumes"];
    prescription["cheese"] = counts["cheese"];
    prescription["eggs"] = counts["eggs"];

    for(var i=0; i<completeMealsList.length; i++) {
      prescription['white_meat'] += completeMealsList[i].white_meat;
      prescription['red_meat'] += completeMealsList[i].red_meat;
      prescription['fish'] += completeMealsList[i].fish;
      prescription['legumes'] += completeMealsList[i].legumes;
      prescription['cheese'] += completeMealsList[i].cheese;
      prescription['eggs'] += completeMealsList[i].eggs;
    }

    return prescription;
  }

  static int getCorrectMeals(eatenList, schedule) {
    var counter = 0;
    for (var i=0; i<eatenList.length; i++) {
      if (eatenList[i].contains(schedule[i])) {
        counter++;
      }
    }
    return counter;
  }

  static String parseDateDbNoneMeal(String dateString) {
    if (dateString == '00-00-00 00:00:00') {
      return dateString;
    }
    else  {
      return DateFormat("y-MM-dd HH:mm:ss").format(DateTime.parse(dateString).toUtc());
    }
  }
}