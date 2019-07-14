
import 'package:flutter/material.dart';
import 'package:nutrition/Meal.dart';
import 'package:nutrition/WeekSummary.dart';

abstract class APIInterface {
  Future<List<dynamic>> getWeekSchedule(int weekNumber, int yearNumber, BuildContext context);

  Future<List<dynamic>> getMealsEaten(String startDate, String endDate, BuildContext context);

  Future<Map<String, dynamic>> getMealPicture(Meal meal, BuildContext context);

  Future<WeekSummary> getWeekSummary(int weekNumber, int yearNumber, BuildContext context);

  Future<int> updateWeekSummary(WeekSummary weekSummary, BuildContext context);

  Future<List<dynamic>> updateSchedule(int weekNumber, int yearNumber, List<dynamic> mealsEaten, List<String> proteinSchedule, BuildContext context);

  Future<int> insertMealDB(Meal lastMeal, BuildContext context);

  Future<int> editMealDB(Meal lastMeal, BuildContext context);

  Future<int> deleteMealDB(Meal lastMeal, BuildContext context);

  Future getStanding(int weekNumber, String date, BuildContext context);

  Future<int> updateStanding(String nowDate, int weekNumber, double score, BuildContext context);
}