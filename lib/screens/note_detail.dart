import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:note_keeper_application/models/note.dart';
import 'package:note_keeper_application/utils/database_helper.dart';
import 'package:note_keeper_application/screens/note_list.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  // var selectedValue = _priorities[0];
  final String appBarTitle;
  final Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          // When user press Back Navigation button in device
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(15.0),
              child: ListView(
                children: [
                  ListTile(
                      title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint("The Selected Value: $valueSelectedByUser");
                        updatePriorityAsInt(valueSelectedByUser);
                        print("here ---> ${note.priority}");
                      });
                    },
                  )),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint("The changed value: $value");
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Enter the Title",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: TextField(
                      controller: descriptionController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint("The changed value: $value");
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Enter the Description",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: RaisedButton(
                          child: Text(
                            "Save",
                            textScaleFactor: 1.5,
                          ),
                          textColor: Theme.of(context).primaryColorLight,
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            setState(() {
                              debugPrint("Save Button clicked");
                              _save();
                            });
                          },
                        )),
                        Container(
                          width: 10.0,
                        ),
                        Expanded(
                            child: RaisedButton(
                          child: Text(
                            "Delete",
                            textScaleFactor: 1.5,
                          ),
                          textColor: Theme.of(context).primaryColorLight,
                          color: Theme.of(context).primaryColorDark,
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete Button clicked");
                              _delete();
                            });
                          },
                        ))
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  // Convert String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(var value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int Priority to String priority and display it to the user in Dropdown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note Object
  void updateTitle() {
    print("titleController.text-------------- $titleController.text");
    note.title = titleController.text;
  }

  // Update the description of Note Object
  void updateDescription() {
    print("descriptionController.text-------------- $descriptionController.text");
    note.description  = descriptionController.text;
  }

  // Save data to Databse
  void _save() async {
    moveToLastScreen();
    print(note);
    print(note.id);
    note.date = DateFormat.yMMMd().format(DateTime.now());
    print("here --------Insert ------sdf-");
    int result;

    if (note.id != null) {
      // Case:1 Update operation
      print("here -------- Upate -----------");
      result = await helper.updateNote(note);
    } else {
      print(note.title);
      print(note.priority);
      print(note.date);
      print(note.description);
      print("here --------Insert -------");
      // Case:2 Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved successfully');
    } else {
      _showAlertDialog('Status', 'Problem saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // case 1: If user is trying to delete the NEW NOTE i.e he has come to
    //  the detail page by pressing the FAB of Notelist page
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
    }
    // case 2: User is trying to delete the old Note that already has a valid ID
    int result = await helper.deleteNote(note.id);

    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
