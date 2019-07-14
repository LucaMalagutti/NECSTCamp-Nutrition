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

class EditDeleteMealRoute extends StatefulWidget {
  Meal editMeal;
  final List<Meal> mealsList;
  final bool isSnack;

  EditDeleteMealRoute({
    Key key,
    @required this.editMeal,
    @required this.mealsList,
    @required this.isSnack,
  }) : super(key: key);
  @override
  EditDeleteRouteState createState() => new EditDeleteRouteState();
}

class EditDeleteRouteState extends State<EditDeleteMealRoute> {
  bool mealChanged = false;
  bool imageLoading = true;
  bool firstTime = true;
  API api = new API();

  String base64String;
  String base64String2;
  File image;
  File image2;
  Image originalImage;
  Image originalImage2;

  Map originalEditMeal;
  Map mapEditMeal;
  DateTime _dateValue;
  String _dateString;

  int _radioValue;

  double waterRating;
  double sodaRating;

  TextEditingController waterController;
  TextEditingController sodaController;
  TextEditingController alcoholController;
  TextEditingController notesController;

  var _mealTypes = ['breakfast', 'snack', 'lunch', 'dinner'];

  int mealTypeToRadioValue(String type) {
    if (type == 'breakfast') return 0;
    if (type == 'snack') return 1;
    if (type == 'lunch')
      return 2;
    else
      return 3;
  }
  void showWaitForDownloadAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Meal Image still loading!"),
          content:
          new Text("Wait for the image to download to edit or delete this meal."),
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
  void showAlreadyCreatedAlert(bool willPopScope) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("This meal was already created!"),
          content:
              new Text("Change the date or the type of the meal to save it."),
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

  int setExtraProteinValue(white, red, fish, legumes, cheese, eggs) {
    if (white + red + fish + legumes + cheese + eggs > 1) {
      setState(() {
        mapEditMeal['extra_protein'] = 1;
      });
    } else {
      setState(() {
        mapEditMeal['extra_protein'] = 0;
      });
    }
    return mapEditMeal['extra_protein'];
  }

  void onChangedAlcohol(String value) {
    value = value.replaceAll(new RegExp(r','), '.');
    setState(() {
      mealChanged = true;
      mapEditMeal['alcohol_drunk'] = double.parse(value);
    });
  }

  void onChangedNotes(String value) {
    setState(() {
      mealChanged = true;
      mapEditMeal['notes'] = value;
    });
  }

  //MEAL TYPE RADIOS
  void _handleRadioValueChange(int value) {
    setState(() {
      mealChanged = true;
      _radioValue = value;
      mapEditMeal['type'] = _mealTypes[_radioValue];
    });
  }

  int onChangedValue(value) {
    setState((){
      mealChanged = true;
    });
    if (value == 1)
      return 0;
    else
      return 1;
  }

  _showDialog(Map lastMeal, bool edit, bool backButton) {
    Meal myMeal;
    if (edit == true) {
      myMeal = new Meal(
        meal_id: widget.editMeal.meal_id,
        date: mapEditMeal['date'],
        type: mapEditMeal['type'],
        snack_id: mapEditMeal['snack_id'],
        white_meat: mapEditMeal['white_meat'],
        red_meat: mapEditMeal['red_meat'],
        fish: mapEditMeal['fish'],
        legumes: mapEditMeal['legumes'],
        cheese: mapEditMeal['cheese'],
        eggs: mapEditMeal['eggs'],
        water_drunk: mapEditMeal['water_drunk'],
        soda_drunk: mapEditMeal['soda_drunk'],
        alcohol_drunk: mapEditMeal['alcohol_drunk'],
        vegetables: mapEditMeal['vegetables'],
        fruits: mapEditMeal['fruits'],
        carbs: mapEditMeal['carbs'],
        coffee: mapEditMeal['coffee'],
        sweets: mapEditMeal['sweets'],
        fried: mapEditMeal['fried'],
        quantity: mapEditMeal['quantity'],
        extra_protein: mapEditMeal['extra_protein'],
        sweet_extra: mapEditMeal['sweet_extra'],
        image: pickImage(base64String, image),
        image2: pickImage(base64String2, image2),
        score: 0,
        notes: mapEditMeal['notes'],
      );
      if (myMeal.notes == null) {
        myMeal.notes = '';
      }
      myMeal.score = Utils.calculateMealScore(myMeal);
      if (myMeal.type == 'breakfast') {
        myMeal.snack_id = -1;
      }
      if (originalEditMeal['type'] == 'breakfast' && myMeal.type == 'snack') {
        myMeal.snack_id =
            Utils.calculateSnackNumber(widget.mealsList, myMeal);
      }
    }
    else {
      myMeal = Meal.fromJson(originalEditMeal);
    }
    //print(myMeal.image);
    //print(myMeal.image2);
    print(myMeal.toJsonMeal().toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return MyDialog(edit: edit, myMeal: myMeal, backButton: backButton,);
      },
    );
  }


  @override
  void initState() {
    super.initState();
    originalEditMeal = widget.editMeal.toJsonMeal();
    mapEditMeal = widget.editMeal.toJsonMeal();
    _radioValue = mealTypeToRadioValue(mapEditMeal['type']);
    _dateValue = DateTime.parse(widget.editMeal.date);
    _dateString = DateFormat("d/M/yy - HH:mm").format(_dateValue);
    alcoholController = new TextEditingController(
        text: mapEditMeal['alcohol_drunk'].toString());
    notesController = new TextEditingController(
        text: mapEditMeal['notes'].toString());

    waterRating = mapEditMeal['water_drunk'];
    sodaRating = mapEditMeal['soda_drunk'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime) {
      firstTime = false;
      api.getMealPicture(widget.editMeal, context).then((res) {
        setState(() {
          imageLoading = false;
        });
        //print(res['image2']);
        base64String = res['image'];
        base64String2 = res['image2'];
        if (base64String != null) {
          setState(() {
            originalImage = Image.memory(base64Decode(base64String));
          });
        }
        if (base64String2 != null) {
          setState(() {
            originalImage2 = Image.memory(base64Decode(base64String2));
          });
        }
      });
    }
  }

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(widget.editMeal.date),
        firstDate: Utils.getPreviousMonday(DateTime.now()).subtract(new Duration(days: 1)),
        lastDate: new DateTime.now());

    TimeOfDay picked2 = await showTimePicker(
      initialTime: TimeOfDay(hour: DateTime.parse(widget.editMeal.date).hour, minute: DateTime.parse(widget.editMeal.date).minute),
      context: context,
    );
    if (picked != null && picked2 != null)
      setState(() {
        mealChanged = true;
        _dateValue = new DateTime(picked.year, picked.month, picked.day,
            picked2.hour, picked2.minute);
        _dateString = DateFormat("d/M/yy - HH:mm").format(_dateValue);
      });
  }

  Future takePicture() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 500, maxWidth: 500);
    if (picture != null) {
      if (originalImage != null) {
        originalImage2 = null;
        setState(() {
          mealChanged = true;
          image2 = picture;
        });
      }
      else {
        originalImage = null;
        setState(() {
          mealChanged = true;
          image = picture;
        });
      }
    }
  }

  Future selectPicture() async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    if (picture != null) {
      if (originalImage != null) {
        originalImage2 = null;
        setState(() {
          mealChanged = true;
          image2 = picture;
        });
      }
      else {
        originalImage = null;
        setState(() {
          mealChanged = true;
          image = picture;
        });
      }
    }
  }

  String convertImage(File image) {
    if (image != null) {
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64.encode(imageBytes);
      return base64Image;
    }
    return "noImageTaken";
  }

  String pickImage(String base64String, File image) {
    if (image != null) {
      return convertImage(image);
    } else if (base64String != null) {
      return base64String;
    } else
      return "noImageTaken";
  }

  selectImageWidget(File image, Image originalImage) {
    if (image != null)
      return Image.file(image);
    else if (originalImage != null)
      return originalImage;
    else
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text('Take or select a picture of your meal')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ((){
        if (imageLoading == false && mealChanged == true) {
        _dateValue = _dateValue;
        mapEditMeal['date'] =
            DateFormat("y-MM-dd HH:mm:ss").format(_dateValue);
        mapEditMeal['water_drunk'] = waterRating;
        mapEditMeal['soda_drunk'] = sodaRating;

        setExtraProteinValue(
            mapEditMeal['white_meat'],
            mapEditMeal['red_meat'],
            mapEditMeal['fish'],
            mapEditMeal['legumes'],
            mapEditMeal['cheese'],
            mapEditMeal['eggs']);
        bool alreadyCreated = false;
        for (var k = 0; k < widget.mealsList.length; k++) {
          if(mapEditMeal['type']!= 'snack') {
            if ((widget.mealsList[k].date.split(" ")[0] ==
                mapEditMeal['date'].split(" ")[0] &&
                widget.mealsList[k].type == mapEditMeal['type'])) {
              alreadyCreated = true;
              break;
            }
          }
        }
        if (mapEditMeal['date'].split(" ")[0] ==
            originalEditMeal['date'].split(" ")[0] &&
            mapEditMeal['type'] == originalEditMeal['type']) {
          alreadyCreated = false;
        }
        if (alreadyCreated == true) {
          showAlreadyCreatedAlert(true);
          return Future.value(false);
        } else {
          _showDialog(mapEditMeal, true, true);
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
          title: Text("Edit Meal"),
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
                    InkWell(
                      onTap: () {
                        if (imageLoading == false) {
//                          _dateValue = _dateValue;
//                          mapEditMeal['date'] =
//                              DateFormat("y-MM-dd HH:mm:ss").format(_dateValue);
//                          print(mapEditMeal.toString());
//                          setExtraProteinValue(
//                              mapEditMeal['white_meat'],
//                              mapEditMeal['red_meat'],
//                              mapEditMeal['fish'],
//                              mapEditMeal['legumes'],
//                              mapEditMeal['cheese'],
//                              mapEditMeal['eggs']);
                          _showDialog(mapEditMeal, false, false);
                        }
                        else {
                          showWaitForDownloadAlert();
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(8),
                          decoration: new BoxDecoration(
                            color: Color(0xffe53935),
                            borderRadius: BorderRadius.circular(6),
                            border: new Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.delete_forever, color: Colors.black),
                              Text("Delete this meal")
                            ],
                          )),
                    )
                  ],
                ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: <Widget>[
                              Text("Meal Score",
                                  style: TextStyle(
                                      fontSize: 19, fontWeight: FontWeight.w500)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("${mapEditMeal['score']}",
                                    style: TextStyle(
                                        fontSize: 19, fontWeight: FontWeight.w400)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text("Change the meal date and time",
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w500)),
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
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w500)),
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
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w500)),
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
                                  mapEditMeal['white_meat'] =
                                      onChangedValue(mapEditMeal['white_meat']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['white_meat'],
                                  iconString: "Icons/white_meat.png")),
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
                                  mapEditMeal['red_meat'] =
                                      onChangedValue(mapEditMeal['red_meat']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['red_meat'],
                                  iconString: "Icons/red_meat.png")),
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
                                  mapEditMeal['fish'] =
                                      onChangedValue(mapEditMeal['fish']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['fish'],
                                  iconString: "Icons/fish.png")),
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
                                  mapEditMeal['legumes'] =
                                      onChangedValue(mapEditMeal['legumes']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['legumes'],
                                  iconString: "Icons/legumes.png")),
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
                                  mapEditMeal['cheese'] =
                                      onChangedValue(mapEditMeal['cheese']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['cheese'],
                                  iconString: "Icons/cheese.png")),
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
                                  mapEditMeal['eggs'] =
                                      onChangedValue(mapEditMeal['eggs']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['eggs'],
                                  iconString: "Icons/eggs.png")),
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
                      child: Text("Choose your drink",
                          style: TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Water drunk: ", style: TextStyle(fontSize: 15)),
                    StarRating(
                      baseIconString: "Icons/WaterBottle.png",
                      rating: waterRating,
                      onRatingChanged: (waterRating) =>
                          setState(() {
                            mealChanged = true;
                            this.waterRating = waterRating;
                          }),
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
                      onRatingChanged: (sodaRating) =>
                          setState(() {
                            mealChanged = true;
                            this.sodaRating = sodaRating;
                          }),
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
                          controller: alcoholController,
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
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500)))
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
                                  mapEditMeal['vegetables'] =
                                      onChangedValue(mapEditMeal['vegetables']);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(
                                    value: mapEditMeal['vegetables'],
                                    iconString: "Icons/vegetables.png"),
                              )),
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
                                  mapEditMeal['fruits'] =
                                      onChangedValue(mapEditMeal['fruits']);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(
                                    value: mapEditMeal['fruits'],
                                    iconString: "Icons/fruits.png"),
                              )),
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
                                  mapEditMeal['carbs'] =
                                      onChangedValue(mapEditMeal['carbs']);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(
                                    value: mapEditMeal['carbs'],
                                    iconString: "Icons/carbs.png"),
                              )),
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
                                  mapEditMeal['sweets'] =
                                      onChangedValue(mapEditMeal['sweets']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['sweets'],
                                  iconString: "Icons/sweets.png")),
                          Text("Sweets"),
                        ],
                      ),

                    Column(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                setState(() {
                                  mapEditMeal['coffee'] =
                                      onChangedValue(mapEditMeal['coffee']);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SpecialCheckbox(
                                    value: mapEditMeal['coffee'],
                                    iconString: "Icons/coffee.png"),
                              )),
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
                        child: Text("Extra",
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500)))
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
                                  mapEditMeal['sweet_extra'] =
                                      onChangedValue(mapEditMeal['sweet_extra']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['sweet_extra'],
                                  iconString: "Icons/bigCake.png")),
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
                                  mapEditMeal['fried'] =
                                      onChangedValue(mapEditMeal['fried']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['fried'],
                                  iconString: "Icons/fried.png")),
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
                                  mapEditMeal['quantity'] =
                                      onChangedValue(mapEditMeal['quantity']);
                                });
                              },
                              child: SpecialCheckbox(
                                  value: mapEditMeal['quantity'],
                                  iconString: "Icons/quantity.png")),
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
                          controller: notesController,
                          onChanged: (text) {
                            onChangedNotes(text);
                          },
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
                    child: Text("Meal Picture",
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w500))),
                Row(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.camera_alt),
                              ),
                              Text("Camera", style: TextStyle(fontSize: 15))
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.photo),
                              ),
                              Text("Gallery", style: TextStyle(fontSize: 15))
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
                      child: imageLoading
                          ? Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: <Widget>[
                                  Center(
                                      child: SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: CircularProgressIndicator())),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text("Meal picture loading.. ")),
                                  )
                                ],
                              ))
                          : Container(
                              width: 300,
                              decoration: BoxDecoration(
                                border:
                                    new Border.all(color: Colors.black, width: 3),
                              ),
                              child: selectImageWidget(image, originalImage)),
                    )
                  ],
                ),
                    Visibility(
                      visible: ((originalImage != null || image != null)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState((){
                                mealChanged = true;
                                if (originalImage2 != null || image2 != null) {
                                  if (image2 != null) {
                                    image = image2;
                                  }
                                  else {
                                    originalImage = originalImage2;
                                    base64String = base64String2;
                                  }
                                  originalImage2 = null;
                                  base64String2 = null;
                                  image2 = null;
                                }
                                else {
                                  originalImage = null;
                                  base64String = null;
                                  image = null;
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
                      visible: (originalImage2 != null || image2 != null),
                      child: (originalImage2 == null && image2 == null) ? Text('') : Container(
                          width: 300,
                          decoration: BoxDecoration(
                            border:
                            new Border.all(color: Colors.black, width: 3),
                          ),
                          child: selectImageWidget(image2, originalImage2)),
                    ),
                    Visibility(
                      visible: ((originalImage != null || image != null) && (originalImage2 != null || image2 != null)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState((){
                                mealChanged = true;
                                originalImage2 = null;
                                base64String2 = null;
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
            if (imageLoading == false) {
              _dateValue = _dateValue;
              mapEditMeal['date'] =
                  DateFormat("y-MM-dd HH:mm:ss").format(_dateValue);
              mapEditMeal['water_drunk'] = waterRating;
              mapEditMeal['soda_drunk'] = sodaRating;

              setExtraProteinValue(
                  mapEditMeal['white_meat'],
                  mapEditMeal['red_meat'],
                  mapEditMeal['fish'],
                  mapEditMeal['legumes'],
                  mapEditMeal['cheese'],
                  mapEditMeal['eggs']);
              bool alreadyCreated = false;
              for (var k = 0; k < widget.mealsList.length; k++) {
                if(mapEditMeal['type']!= 'snack') {
                  if ((widget.mealsList[k].date.split(" ")[0] ==
                      mapEditMeal['date'].split(" ")[0] &&
                      widget.mealsList[k].type == mapEditMeal['type'])) {
                    alreadyCreated = true;
                    break;
                  }
                }
              }
              if (mapEditMeal['date'].split(" ")[0] ==
                      originalEditMeal['date'].split(" ")[0] &&
                  mapEditMeal['type'] == originalEditMeal['type']) {
                alreadyCreated = false;
              }
              if (alreadyCreated) {
                showAlreadyCreatedAlert(false);
              } else {
                _showDialog(mapEditMeal, true, false);
              }
            }
            else {
              showWaitForDownloadAlert();
            }
          },
          child: Icon(Icons.edit),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  final bool backButton;
  final bool edit;
  final Meal myMeal;
  @override
  MyDialog(
      {Key key,
        @required this.backButton,
      @required this.edit,
      @required this.myMeal,})
      : super(key: key);
  @override
  MyDialogState createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  String capitalizedAction;
  String action;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if(widget.edit == true) {
      capitalizedAction = "Edit";
      action = 'edit';
    }
    else {
      capitalizedAction = 'Delete';
      action = 'delete';
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text("$capitalizedAction Meal"),
        content: Container(
          height: 60,
          child: isLoading ?
          Center(child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator())):
          Text("Do you want to $action this meal?"),
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
            },
          ),
          new FlatButton(
            child: new Text("Confirm"),
            onPressed: () {
              isLoading ? null :
              setState(() {
                isLoading = true;
              });
              if (widget.edit) {
                API().editMealDB(widget.myMeal, context).then((res) {
                  setState(() {
                    isLoading = false;
                  });
                  if (res == 200) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(1);
                  } else {
                    print("COULD NOT EDIT MEAL");
                    Navigator.of(context).pop();
                  }
                });
              } else {
                API().deleteMealDB(widget.myMeal, context).then((res1) {
                  setState(() {
                    isLoading = false;
                  });
                  if (res1 == 200) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(1);
                  } else {
                    print("COULD NOT DELETE MEAL");
                    Navigator.of(context).pop();
                  }
                });
              }
            },
          ),
        ]);
  }
}
