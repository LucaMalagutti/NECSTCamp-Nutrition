import 'package:flutter/material.dart';

class Meal {
  int meal_id;
  String image;
  String image2;
  String date;
  String type;
  int snack_id;
  int white_meat;
  int red_meat;
  int fish;
  int legumes;
  int eggs;
  int cheese;
  double water_drunk;
  double soda_drunk;
  double alcohol_drunk;
  int vegetables;
  int fruits;
  int carbs;
  int coffee;
  int sweets;
  int fried;
  int quantity;
  int sweet_extra;
  int extra_protein;
  double score;
  String notes;

  Meal({this.meal_id,
      @required this.image,
      @required this.image2,
      @required this.date,
      @required this.type,
      @required this.snack_id,
      @required this.white_meat,
      @required this.red_meat,
      @required this.fish,
      @required this.legumes,
      @required this.cheese,
      @required this.eggs,
      @required this.water_drunk,
      @required this.soda_drunk,
      @required this.alcohol_drunk,
      @required this.vegetables,
      @required this.fruits,
      @required this.carbs,
      @required this.coffee,
      @required this.sweets,
      @required this.fried,
      @required this.quantity,
      @required this.sweet_extra,
      @required this.extra_protein,
  @required this.score,
  @required this.notes});

  Meal.fromJson(Map<String, dynamic> json)
      : meal_id = json['meal_id'],
        date = DateTime.parse(json['date']).toString(),
        type = json['type'],
        snack_id = json['snack_id'],
        white_meat = json['white_meat'],
        red_meat = json['red_meat'],
        fish = json['fish'],
        legumes = json['legumes'],
        cheese = json['cheese'],
        eggs = json['eggs'],
        water_drunk = json['water_drunk'] + 0.0,
        soda_drunk = json['soda_drunk'] + 0.0,
        alcohol_drunk = json['alcohol_drunk'] + 0.0,
        vegetables = json['vegetables'],
        fruits = json['fruits'],
        coffee = json['coffee'],
        sweets = json['sweets'],
        carbs = json['carbs'],
        fried = json['fried'],
        quantity = json['quantity'],
        extra_protein = json['extra_protein'],
        sweet_extra = json['sweet_extra'],
        image = json['image'],
        image2 = json['image2'],
        score = json['score'] + 0.0,
        notes = json['notes'];


  Map<String, dynamic> toJsonMeal() => {
        'meal_id': meal_id,
        'date': date,
        'type': type,
        'snack_id': snack_id,
        'white_meat': white_meat,
        'red_meat': red_meat,
        'fish': fish,
        'legumes': legumes,
        'cheese': cheese,
        'eggs': eggs,
        'water_drunk': water_drunk,
        'soda_drunk': soda_drunk,
        'alcohol_drunk': alcohol_drunk,
        'vegetables': vegetables,
        'fruits': fruits,
        'carbs': carbs,
        'coffee': coffee,
        'sweets': sweets,
        'fried': fried,
        'quantity': quantity,
        'extra_protein': extra_protein,
        'sweet_extra': sweet_extra,
        'image': image,
        'image2': image2,
        'score': score,
        'notes': notes,
      };

  Map<String, dynamic> toJsonNewMeal() => {
        'date': date,
        'type': type,
        'snack_id': snack_id,
        'white_meat': white_meat,
        'red_meat': red_meat,
        'fish': fish,
        'legumes': legumes,
        'cheese': cheese,
        'eggs': eggs,
        'water_drunk': water_drunk,
        'soda_drunk': soda_drunk,
        'alcohol_drunk': alcohol_drunk,
        'vegetables': vegetables,
        'fruits': fruits,
        'carbs': carbs,
        'coffee': coffee,
        'sweets': sweets,
        'fried': fried,
        'quantity': quantity,
        'sweet_extra': sweet_extra,
        'extra_protein': extra_protein,
        'image': image,
        'image2': image2,
        'score': score,
        'notes': notes,
      };
}
