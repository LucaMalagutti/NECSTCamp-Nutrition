import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nutrition/API.dart';
import 'package:nutrition/SpecialCheckbox.dart';
import 'package:nutrition/StarRating.dart';
import 'package:nutrition/Utils.dart';
import 'Meal.dart';

class NewMealRoute extends StatefulWidget {
  final int tileIndex;
  final List<Meal> mealsList;
  final bool isSnack;

  NewMealRoute({Key key, this.tileIndex, @required this.mealsList, @required this.isSnack}) : super(key: key);
  @override
  NewMealRouteState createState() => new NewMealRouteState();
}

class NewMealRouteState extends State<NewMealRoute> {
  bool mealChanged = false;
  bool isLoading = false;
  File image;
  File image2;

  double waterRating = 0;
  double sodaRating = 0;

  DateTime _dateValue;
  String _dateDB;
  String _dateString;

  int _radioValue;

  int _whiteMeatIsChecked = 0;
  int _redMeatIsChecked = 0;
  int _fishIsChecked = 0;
  int _legumesIsChecked = 0;
  int _cheeseIsChecked = 0;
  int _eggsIsChecked = 0;

  //double _waterDrunk = 0.0;
  //double _sodaDrunk = 0.0;
  double _alcoholDrunk = 0.0;

  int _vegetablesIsChecked = 0;
  int _fruitsIsChecked = 0;
  int _carbsIsChecked = 0;
  int _coffeeIsChecked = 0;
  int _sweetsIsChecked = 0;
  int _friedIsChecked = 0;
  int _sweetExtraIsChecked = 0;
  int _quantityIsChecked = 0;
  int _extraProtein = 0;
  String mealNotes = '';

  var _currentMealTypeSelected;
  var _mealTypes = ['breakfast','snack','lunch', 'dinner'];

  @override
  void initState() {
    super.initState();
    if(widget.isSnack) {
      _radioValue = 0;
      _currentMealTypeSelected = 'breakfast';
    } else {
      if (widget.tileIndex == null) {
        var lunchThreshold = DateTime.now();
        lunchThreshold = new DateTime(
            lunchThreshold.year,
            lunchThreshold.month,
            lunchThreshold.day,
            18,
            0,
            0,
            0,
            0);
        if (DateTime.now().isBefore(lunchThreshold)) {
          _radioValue = 2;
          _currentMealTypeSelected = 'lunch';
        }
        else {
          _radioValue = 3;
          _currentMealTypeSelected = 'dinner';
        }
      }
      else {
        if (widget.tileIndex%2==0) {
          _radioValue = 2;
          _currentMealTypeSelected = 'lunch';
        }
        else {
          _radioValue = 3;
          _currentMealTypeSelected = 'dinner';
        }
      }
    }
    if (widget.tileIndex == null || getDateByTileIndex(DateTime.now(), widget.tileIndex).isAfter(DateTime.now())) {
      _dateValue = DateTime.now();
    }
    else {
      _dateValue = getDateByTileIndex(DateTime.now(), widget.tileIndex);
    }
    _dateDB = DateFormat("y-MM-dd HH:mm:ss").format(_dateValue);
    _dateString = DateFormat("d/M/yy - HH:mm").format(_dateValue);
  }

  DateTime getDateByTileIndex(now, index) {
    now = Utils.getPreviousMonday(now);
    return now.add(new Duration(days: ((index / 2).floor())));
  }

  int setExtraProteinValue(white, red, fish, legumes, cheese, eggs) {
    if(white+red+fish+legumes+cheese+eggs>1) {
      _extraProtein = 1;
    }
    else {_extraProtein = 0;}
    return _extraProtein;
  }
  //MEAL TYPE RADIOS
  void _handleRadioValueChange(int value) {
    setState(() {
      mealChanged = true;
      _radioValue = value;
      _currentMealTypeSelected = _mealTypes[_radioValue];
    });
  }

  int onChangedValue(value) {
    setState(() {
      mealChanged = true;
    });
    if(value == 1) return 0;
    else return 1;
  }

  void onChangedAlcohol(String value) {
    value = value.replaceAll(new RegExp(r','), '.');
    print(value);
    setState(() {
      mealChanged = true;
      _alcoholDrunk = double.parse(value);
    });
  }

  void onChangedNotes(String value) {
    print(value);
    setState(() {
      mealChanged = true;
      mealNotes = value;
    });
  }

  DateTime getInitialDate() {
    if (widget.tileIndex == null || getDateByTileIndex(DateTime.now(), widget.tileIndex).isAfter(DateTime.now())) {
      _dateValue = DateTime.now();
    }
    else {
      _dateValue = getDateByTileIndex(DateTime.now(), widget.tileIndex);
    }
    return _dateValue;
  }


  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: getInitialDate(),
        firstDate: Utils.getPreviousMonday(DateTime.now()).subtract(new Duration(days: 1)),
        lastDate: new DateTime.now());

    TimeOfDay picked2 = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (picked != null && picked2 != null)
      setState(() {
        mealChanged = true;
        _dateValue = new DateTime(picked.year, picked.month, picked.day, picked2.hour, picked2.minute);
        _dateString = DateFormat("d/M/yy - HH:mm").format(_dateValue);
        _dateDB = DateFormat("y-MM-dd HH:mm:ss").format(_dateValue);
      });
  }

  void _showDialog(Meal lastMeal, bool backButton) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return MyDialog(backButton: backButton, isLoading: isLoading, lastMeal: lastMeal);
      },
    );
  }

  void showAlreadyCreatedAlert(bool willPopScope) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("This meal was already created!"),
          content: new Text("Change the date or the type of the meal to save it."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            willPopScope ?  FlatButton(
              child: new Text("Discard"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ): null,
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

  Future takePicture() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
    setState(() {
      mealChanged = true;
      if (image == null) {
        image = picture;
      }
      else {
        image2 = picture;
      }
    });
  }

  Future selectPicture() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    setState(() {
      mealChanged = true;
      if (image == null) {
        image = picture;
      }
      else {
        image2 = picture;
      }
    });
  }

  String convertImage(File image) {
    if(image != null) {
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64.encode(imageBytes);
      return base64Image;
    }
    return "noImageTaken";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ((){
        if(mealChanged == true) {
          var myMeal = new Meal(
            score: 0,
            date: _dateDB,
            type: _currentMealTypeSelected,
            snack_id: -1,
            white_meat: _whiteMeatIsChecked,
            red_meat: _redMeatIsChecked,
            fish: _fishIsChecked,
            legumes: _legumesIsChecked,
            cheese: _cheeseIsChecked,
            eggs: _eggsIsChecked,
            water_drunk: waterRating,
            soda_drunk: sodaRating,
            alcohol_drunk: _alcoholDrunk,
            vegetables: _vegetablesIsChecked,
            fruits: _fruitsIsChecked,
            carbs: _carbsIsChecked,
            coffee: _coffeeIsChecked,
            sweets: _sweetsIsChecked,
            fried: _friedIsChecked,
            quantity: _quantityIsChecked,
            extra_protein: setExtraProteinValue(
                _whiteMeatIsChecked, _redMeatIsChecked,
                _fishIsChecked, _legumesIsChecked, _cheeseIsChecked,
                _eggsIsChecked),
            sweet_extra: _sweetExtraIsChecked,
            image: convertImage(image),
            image2: convertImage(image2),
            notes: mealNotes,
          );
          if (myMeal.notes == null) {
            myMeal.notes = '';
          }
          myMeal.score = Utils.calculateMealScore(myMeal);
          myMeal.snack_id = Utils.calculateSnackNumber(widget.mealsList, myMeal);

          String json = myMeal.toJsonNewMeal().toString();
          print(json);

          bool alreadyCreated = false;

          for (var k = 0; k < widget.mealsList.length; k++) {
            if (myMeal.type != 'snack') {
              if (widget.mealsList[k].date.split(" ")[0] ==
                  myMeal.date.split(" ")[0] &&
                  widget.mealsList[k].type == myMeal.type) {
                alreadyCreated = true;
                break;
              }
            }
          }
          if (alreadyCreated) {
            showAlreadyCreatedAlert(true);
            return Future.value(false);
          }
          else {
            _showDialog(myMeal, true);
            return Future.value(false);
          }
        }
        else {
          return Future.value(true);
        }
      }),
      child: Scaffold(
        backgroundColor: const Color(0xffd9dde2),
        appBar: AppBar(
          title: Text("New Meal"),
        ),
        body: SingleChildScrollView(
          child: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(8),
              ),
              //color: Colors.white,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(16),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                      Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text("Change the meal date and time",
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("$_dateString", style: TextStyle(fontSize: 16)),
                    IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(Icons.calendar_today, size: 30),
                      onPressed: _selectDate,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("Change the meal type",
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Visibility(
                      visible: widget.isSnack,
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Radio(
                              value: 0,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text("Breakfast")
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.isSnack,
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Radio(
                              value: 1,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text("Snack")
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !widget.isSnack,
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Radio(
                              value: 2,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text("Lunch")
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !widget.isSnack,
                      child: Expanded(
                        child: Column(
                          children: <Widget>[
                            Radio(
                              value: 3,
                              groupValue: _radioValue,
                              onChanged: _handleRadioValueChange,
                            ),
                            Text("Dinner")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Choose the kind of protein",
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _whiteMeatIsChecked = onChangedValue(_whiteMeatIsChecked);
                              });
                            },
                            child: SpecialCheckbox(value: _whiteMeatIsChecked, iconString: "Icons/white_meat.png")
                          ),
                          Text("White Meat")
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _redMeatIsChecked = onChangedValue(_redMeatIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _redMeatIsChecked, iconString: "Icons/red_meat.png")
                          ),
                          Text("Red Meat"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _fishIsChecked = onChangedValue(_fishIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _fishIsChecked, iconString: "Icons/fish.png")
                          ),
                          Text("Fish"),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _legumesIsChecked = onChangedValue(_legumesIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _legumesIsChecked, iconString: "Icons/legumes.png")
                          ),
                          Text("Legumes"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _cheeseIsChecked = onChangedValue(_cheeseIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _cheeseIsChecked, iconString: "Icons/cheese.png")
                          ),
                          Text("Cheese"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _eggsIsChecked = onChangedValue(_eggsIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _eggsIsChecked, iconString: "Icons/eggs.png")
                          ),
                          Text("Eggs"),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("Choose your drinks",
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                        child: Text("Water drunk: ", style: TextStyle(fontSize: 15))
                    ),
                    StarRating(
                      baseIconString: "Icons/WaterBottle.png",
                      rating: waterRating,
                      onRatingChanged: (waterRating) => setState(() {mealChanged = true;this.waterRating = waterRating;}),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Soda drunk: ", style: TextStyle(fontSize: 15)),
                    StarRating(
                      baseIconString: "Icons/Can.png",
                      rating: sodaRating,
                      onRatingChanged: (sodaRating) => setState(() {mealChanged = true; this.sodaRating = sodaRating;}),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Alcohol drunk: ", style: TextStyle(fontSize: 15)),
                    Container(
                        height: 65,
                        width: 140,
                        child: TextField(
                          onChanged: (text) {
                            onChangedAlcohol(text);
                          },
                          maxLength: 4,
                          maxLines: 1,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))],
                          decoration: InputDecoration(
                            counterText: '',
                            counterStyle: TextStyle(fontSize: 0),
                            hintText: 'Insert liters drunk',
                          ),
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Select all that apply",
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _vegetablesIsChecked = onChangedValue(_vegetablesIsChecked);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SpecialCheckbox(value: _vegetablesIsChecked, iconString: "Icons/vegetables.png"),
                              )
                          ),
                          Text("Vegetables"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _fruitsIsChecked = onChangedValue(_fruitsIsChecked);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(value: _fruitsIsChecked, iconString: "Icons/fruits.png"),
                              )
                          ),
                          Text("Fruits"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _carbsIsChecked = onChangedValue(_carbsIsChecked);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(value: _carbsIsChecked, iconString: "Icons/carbs.png"),
                              )
                          ),
                          Text("Carbs"),
                        ],
                      ),
                    ),
                    ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                     Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _sweetsIsChecked = onChangedValue(_sweetsIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _sweetsIsChecked, iconString: "Icons/sweets.png")
                          ),
                          Text("Sweets"),
                        ],
                      ),

                     Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _coffeeIsChecked = onChangedValue(_coffeeIsChecked);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(value: _coffeeIsChecked, iconString: "Icons/coffee.png"),
                              )
                          ),
                          Text("Coffee"),
                        ],
                      ),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Extra", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _sweetExtraIsChecked = onChangedValue(_sweetExtraIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _sweetExtraIsChecked, iconString: "Icons/bigCake.png")
                          ),
                          Text("Sweet Extra", textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _friedIsChecked = onChangedValue(_friedIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _friedIsChecked, iconString: "Icons/fried.png")
                          ),
                          Text("Fried"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _quantityIsChecked = onChangedValue(_quantityIsChecked);
                                });
                              },
                              child: SpecialCheckbox(value: _quantityIsChecked, iconString: "Icons/quantity.png")
                          ),
                          Text("High Quantity"),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("Notes", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500)))
                  ],
                ),
                Container(
                    width: 220,
                    child: TextField(
                      onChanged: (text) {
                        onChangedNotes(text);
                      },
                      textAlign: TextAlign.center,
                      maxLength: 140,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        counterText: '',
                        counterStyle: TextStyle(fontSize: 0),
                        hintText: 'Insert notes about the meal',
                      ),
                    )),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Meal Picture", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))),
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        takePicture();
                      },
                      child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(12),
                          decoration: new BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(8),
                            border: new Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.camera_alt),
                              ),
                              Text("Camera",
                                  style: TextStyle(fontSize: 15))
                            ],
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        selectPicture();
                      },
                      child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(12),
                          decoration: new BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(8),
                            border: new Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.photo),
                              ),
                              Text("Gallery",
                                  style: TextStyle(fontSize: 15))
                            ],
                          )),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: image == null ? Text("Take or select a picture of your meal") :
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              border: new Border.all(color: Colors.black, width: 3),
                            ),
                            child: Image.file(image)
                          ),
                    )
                  ],
                ),
                    Visibility(
                      visible: (image != null),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState((){
                                image = null;
                                if (image2 != null) {
                                  image = image2;
                                  image2 = null;
                                }
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(8),
                                decoration: new BoxDecoration(
                                  color: Color(0xffe53935),
                                  borderRadius: BorderRadius.circular(6),
                                  border: new Border.all(color: Colors.black, width: 2),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.delete_forever, color: Colors.black),
                                    Text("Remove first meal picture")
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: (image2 != null),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: image2 == null ? Text("") : Container(width: 300,
                            decoration: BoxDecoration(
                              border: new Border.all(color: Colors.black, width: 3),
                            ),
                            child: Image.file(image2)
                        ),
                      ),
                    ),
                    Visibility(
                      visible: (image2 != null && image != null),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                image2 = null;
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(8),
                                decoration: new BoxDecoration(
                                  color: Color(0xffe53935),
                                  borderRadius: BorderRadius.circular(6),
                                  border: new Border.all(color: Colors.black, width: 2),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.delete_forever, color: Colors.black),
                                    Text("Remove second meal picture")
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),

              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var myMeal = new Meal(
              score: 0,
              date: _dateDB,
              type: _currentMealTypeSelected,
              snack_id: -1,
              white_meat: _whiteMeatIsChecked,
              red_meat: _redMeatIsChecked,
              fish: _fishIsChecked,
              legumes: _legumesIsChecked,
              cheese: _cheeseIsChecked,
              eggs: _eggsIsChecked,
              water_drunk: waterRating,
              soda_drunk: sodaRating,
              alcohol_drunk: _alcoholDrunk,
              vegetables: _vegetablesIsChecked,
              fruits: _fruitsIsChecked,
              carbs: _carbsIsChecked,
              coffee: _coffeeIsChecked,
              sweets: _sweetsIsChecked,
              fried: _friedIsChecked,
              quantity: _quantityIsChecked,
              extra_protein: setExtraProteinValue(_whiteMeatIsChecked, _redMeatIsChecked,
                  _fishIsChecked, _legumesIsChecked, _cheeseIsChecked, _eggsIsChecked),
              sweet_extra: _sweetExtraIsChecked,
              image: convertImage(image),
              image2: convertImage(image2),
              notes: mealNotes
            );
            if (myMeal.notes == null) {
              myMeal.notes = '';
            }
            myMeal.snack_id = Utils.calculateSnackNumber(widget.mealsList, myMeal);
            myMeal.score = Utils.calculateMealScore(myMeal);

            String json = myMeal.toJsonNewMeal().toString();
            print(json);

            bool alreadyCreated = false;

            for(var k=0; k<widget.mealsList.length; k++) {
              if(myMeal.type != 'snack') {
                if (widget.mealsList[k].date.split(" ")[0] ==
                    myMeal.date.split(" ")[0] &&
                    widget.mealsList[k].type == myMeal.type) {
                  alreadyCreated = true;
                  break;
                }
              }
            }
            if (alreadyCreated) {showAlreadyCreatedAlert(false);}
            else {_showDialog(myMeal, false);}
          },
          child: Icon(Icons.save),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  bool backButton;
  bool isLoading;
  final Meal lastMeal;
  @override
  MyDialog({Key key, @required this.backButton, @required this.lastMeal, @required this.isLoading}) : super(key: key);
  @override
  MyDialogState createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: (widget.lastMeal.alcohol_drunk != 3.17) ? Text("Submit Meal") : Text("dio non mi risponde, e m'ha visualizzato"),
      content: Container(
        height: 60,
        child: !widget.isLoading ?
        Text("Do you want to save this meal?") :
        Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(value: null))),
      ),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
    widget.backButton ?
    FlatButton(
        child: new Text("Discard Changes"),
    onPressed: () {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    },
    ) :
    FlatButton(
    child: new Text("Undo"),
    onPressed: () {
    Navigator.of(context).pop();
    },),
        new FlatButton(
          child: new Text("Confirm"),
          onPressed: () {
            widget.isLoading ? null :
            setState(() {
              widget.isLoading = true;
            });
            API().insertMealDB(widget.lastMeal, context).then((res) {
              setState(() {
                widget.isLoading = false;
              });
              if (res == 200) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(1);
              }
              else {
                print("COULD NOT INSERT NEW MEAL");
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ],
    );
  }
}