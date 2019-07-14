import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nutrition/API_interface.dart';
import 'package:nutrition/Utils.dart';
import 'Meal.dart';
import 'package:login/login.dart';
import 'WeekSummary.dart';
import 'package:http/http.dart' as http;

class API implements APIInterface {
  static final API _singleton = new API._internal();

  factory API() {
    return _singleton;
  }

  API._internal();

  String baseAddress = 'api.necstcamp.necst.it';
  //String baseAddress = '10.0.2.2:1378';

  Future<List<dynamic>> getWeekSchedule(int weekNumber, int yearNumber, BuildContext context) async {
    var httpClient = new http.Client();
    //print(responseAuth.statusCode);
    if (Auth.of(context).isLoggedIn()) {
      final responseGetSchedule = await httpClient.get(new Uri.https(baseAddress,"/nutri/getschedule", {"week": weekNumber.toString(), "year": yearNumber.toString()}),
              headers: {"token": Auth.of(context).user.token});
      List<dynamic> weekList;
      List<dynamic> proteinCounts;
      List<dynamic> container = [];
      if(responseGetSchedule.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      if (responseGetSchedule.statusCode == 204) {
        final responseCreateSchedule = await httpClient.post(
            "https://"+baseAddress+"/nutri/createschedule",
            headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
            body: json.encode({"input": {"week": weekNumber, "year": yearNumber}}));
        if (responseCreateSchedule.statusCode == 200) {
          weekList = jsonDecode(responseCreateSchedule.body)['schedule_json_path']['weeklySchedule'];
          proteinCounts = jsonDecode(responseCreateSchedule.body)['schedule_json_path']['proteinCounts'];
        } else {
          print("ERROR CREATING SCHEDULE");
        }
      } else {
        weekList = jsonDecode(responseGetSchedule.body)['schedule_json_path']['weeklySchedule'];
        proteinCounts = jsonDecode(responseGetSchedule.body)['schedule_json_path']['proteinCounts'];
      }
      container.add(weekList);
      container.add(proteinCounts);
      return container;
    }
    print("USER NOT LOGGED IN");
    return [];
  }

  Future<List<dynamic>> getMealsEaten(String startDate, String endDate, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseGetMeals = await httpClient.get(new Uri.https(baseAddress,"/nutri/getmeal", {"start_date": startDate, "end_date": endDate}),
          headers: {"token": Auth.of(context).user.token});
      if(responseGetMeals.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      if (responseGetMeals.statusCode == 200) {
        return jsonDecode(responseGetMeals.body);
      }
    }
    //print("ERROR IN GET MEALS");
    return [];
  }

  Future<Map<String, dynamic>> getMealPicture(Meal meal, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn() && meal.image != 'noImageTaken') {
      final responseGetMealPicture = await httpClient.get(new Uri.https(baseAddress,"/nutri/getmealpicture", {"meal_id": meal.meal_id.toString(), "image": meal.image}),
          headers: {"token": Auth.of(context).user.token});
      if(responseGetMealPicture.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      if (responseGetMealPicture.statusCode == 200) {
        //print(jsonDecode(responseGetMealPicture.body));
        return jsonDecode(responseGetMealPicture.body);
      }
    }
    //print("ERROR IN GET MEAL PICTURE");
    return {"image": null, "image2": null};
  }

  Future<WeekSummary> getWeekSummary(int weekNumber, int yearNumber, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseGetSummary = await httpClient.get(new Uri.https(baseAddress,"/nutri/getsummary",{"week": weekNumber.toString(), "year": yearNumber.toString()}),
          headers: {"token": Auth.of(context).user.token});
      if(responseGetSummary.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return WeekSummary.fromJson(jsonDecode(responseGetSummary.body));
    }
    print("USER NOT LOGGED IN");
    return WeekSummary(
        -1, 0, 0.0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  }

  Future<int> updateWeekSummary(WeekSummary weekSummary, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseUpdateSummary = await httpClient.post(
          "https://"+baseAddress+"/nutri/updatesummary",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": weekSummary.toJsonSummary()}));
      if(responseUpdateSummary.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return responseUpdateSummary.statusCode;
    }
    return 500;
  }

  Future<List<dynamic>> updateSchedule(int weekNumber, int yearNumber, List<dynamic> mealsEaten, List<String> proteinSchedule, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseUpdateSchedule = await httpClient.post(
          "https://"+baseAddress+"/nutri/updateschedule",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": {"week": weekNumber, "year": yearNumber,"proteinSchedule": proteinSchedule, "mealsEaten": mealsEaten}}));
      if(responseUpdateSchedule.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      if (responseUpdateSchedule.statusCode == 200) {
        List<dynamic> container = [];
        List<dynamic> weekList = jsonDecode(responseUpdateSchedule.body)['schedule_json_path']['weeklySchedule'];
        List<dynamic> proteinCounts = jsonDecode(responseUpdateSchedule.body)['schedule_json_path']['proteinCounts'];
        container.add(weekList);
        container.add(proteinCounts);
        return container;
      }
    }
    return [];
  }

  Future<int> insertMealDB(Meal lastMeal, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseInsertMeal = await httpClient.post(
          "https://"+baseAddress+"/nutri/insmeal",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": lastMeal.toJsonNewMeal()}));
      if(responseInsertMeal.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return responseInsertMeal.statusCode;
    }
    return 500;
  }

  Future<int> editMealDB(Meal lastMeal, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseInsertMeal = await httpClient.post(
          "https://"+baseAddress+"/nutri/insmeal",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": lastMeal.toJsonMeal()}));
      if(responseInsertMeal.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return responseInsertMeal.statusCode;
    }
    return 500;
  }

  Future<int> deleteMealDB(Meal lastMeal, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseDeleteMeal = await httpClient.post(
          "https://"+baseAddress+"/nutri/delmeal",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": lastMeal.toJsonMeal()}));
      if(responseDeleteMeal.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return responseDeleteMeal.statusCode;
    }
    return 500;
  }

  Future<List<dynamic>> getStanding(int weekNumber, String date, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseGetStanding = await httpClient.get(new Uri.https(baseAddress,"/nutri/getstanding",{"week": weekNumber.toString(), "date": date}),
          headers: {"token": Auth.of(context).user.token});
      if(responseGetStanding.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      //print(jsonDecode(responseGetUsers.body));
      return Utils.createStanding(jsonDecode(responseGetStanding.body));
    }
    return [];
  }

  Future<int> updateStanding(String nowDate, int weekNumber, double score, BuildContext context) async {
    var httpClient = new http.Client();
    if (Auth.of(context).isLoggedIn()) {
      final responseUpdateStanding = await httpClient.post(
          "https://"+baseAddress+"/nutri/updateStanding",
          headers: {"token": Auth.of(context).user.token, "Content-Type": 'application/json'},
          body: json.encode({"input": {"date": nowDate, "week": weekNumber, "score": score}}));
      if(responseUpdateStanding.statusCode == 401) {
        Utils.onUserNotAuthenticated(context);
      }
      return responseUpdateStanding.statusCode;
    }
    return 500;
  }
}