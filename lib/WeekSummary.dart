class WeekSummary {
  int year;
  int week;
  double score;
  int whiteMeatCount;
  int redMeatCount;
  int fishCount;
  int legumesCount;
  int cheeseCount;
  int eggsCount;
  double waterCount;
  double sodaCount;
  double alcoholCount;
  int carbsCount;
  int vegetablesCount;
  int fruitsCount;
  int coffeeCount;
  int sweetsCount;
  int friedCount;
  int quantityCount;
  int extraProteinCount;
  int sweetExtraCount;
  int scheduleChanges;
  int totalExtra;

  WeekSummary(this.year, this.week, this.score, this.whiteMeatCount, this.redMeatCount,
      this.fishCount, this.legumesCount, this.cheeseCount, this.eggsCount,
      this.waterCount, this.sodaCount, this.alcoholCount, this.carbsCount,
      this.vegetablesCount, this.fruitsCount, this.sweetsCount, this.coffeeCount, this.friedCount,
      this.quantityCount, this.extraProteinCount, this.sweetExtraCount, this.scheduleChanges,
      this.totalExtra);

  WeekSummary.fromJson(Map<String, dynamic> json)
      : year = json['year'],
        week = json['week'],
        score = json['score'] + 0.0,
        whiteMeatCount = json['white_meat'],
        redMeatCount = json['red_meat'],
        fishCount = json['fish'],
        legumesCount = json['legumes'],
        cheeseCount = json['cheese'],
        eggsCount = json['eggs'],
        waterCount = json['water']+0.0,
        sodaCount = json['soda']+0.0,
        alcoholCount = json['alcohol']+0.0,
        vegetablesCount = json['vegetables'],
        fruitsCount = json['fruits'],
        carbsCount = json['carbs'],
        coffeeCount = json['coffee'],
        sweetsCount = json['sweets'],
        friedCount = json['fried'],
        quantityCount = json['quantity'],
        extraProteinCount = json['extra_protein'],
        sweetExtraCount = json['sweet_extra'],
        scheduleChanges = json['schedule_changes'],
        totalExtra = json['totalExtra'];

  Map<String, dynamic> toJsonSummary() => {
    'year': year,
    'week': week,
    'score': score,
    'white_meat': whiteMeatCount,
    'red_meat': redMeatCount,
    'fish': fishCount,
    'legumes': legumesCount,
    'cheese': cheeseCount,
    'eggs': eggsCount,
    'water': waterCount,
    'soda': sodaCount,
    'alcohol': alcoholCount,
    'vegetables': vegetablesCount,
    'fruits': fruitsCount,
    'carbs': carbsCount,
    'coffee': coffeeCount,
    'sweets': sweetsCount,
    'fried': friedCount,
    'quantity': quantityCount,
    'extra_protein': extraProteinCount,
    'sweet_extra': sweetExtraCount,
    'schedule_changes': scheduleChanges,
    'totalExtra': totalExtra,
  };

}