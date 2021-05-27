import 'package:flutter/material.dart';

class NoteDetail extends StatefulWidget {
  String appBarTitle;

  NoteDetail(this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['HIgh', 'Low'];
  var selectedValue = _priorities[0];
  String appBarTitle;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: ListView(
            children: [
              ListTile(
                  title: DropdownButton(
                items: _priorities.map((String priorityItmes) {
                  return DropdownMenuItem(
                    value: priorityItmes,
                    child: Text(priorityItmes),
                  );
                }).toList(),
                style: textStyle,
                value: selectedValue,
                onChanged: (valueSelectedByUser) {
                  setState(() {
                    debugPrint("The Selected Value: $valueSelectedByUser");
                    selectedValue = valueSelectedByUser;
                  });
                },
              )),
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onSubmitted: (value) {
                    debugPrint("The changed value: $value");
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
                  onSubmitted: (value) {
                    debugPrint("The changed value: $value");
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
                        });
                      },
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
