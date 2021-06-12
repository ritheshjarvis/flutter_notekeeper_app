import 'package:flutter/material.dart';
import 'dart:async';
import 'package:note_keeper_application/models/note.dart';
import 'package:note_keeper_application/utils/database_helper.dart';
import 'package:note_keeper_application/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body: getListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "FAB",
        onPressed: () {
          navigateToNoteDetail(Note('', '', 2), "Add Note");
          debugPrint("FAB clicked");
        },
      ),
    );
  }

  getListView() {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;

    if (count != 0) {
      return ListView.builder(
          itemCount: count,
          itemBuilder: (BuildContext context, int position) {
            return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList[position].priority),
                  child: getPriorityIcon(this.noteList[position].priority),
                ),
                title: Text(
                  this.noteList[position].title,
                  style: textStyle,
                ),
                subtitle: Text(this.noteList[position].date),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    _delete(context, noteList[position]);
                  },
                ),
                onTap: () {
                  navigateToNoteDetail(this.noteList[position], "Edit Note");
                  debugPrint("ListTile tapped");
                },
              ),
            );
          });
    } else {
      return ListView(children: [
        getAssetImage(),
        getCopyrightString()
        // Center(
        //     child: Text(" © rithesh_b_rao 2021 ",
        //         style: TextStyle(fontSize: 15.0)))
      ]);
    }
  }

  getCopyrightString() {
    return Container(
      // margin: EdgeInsets.only(bottom: 15.0),
      child: Center(
          child:
              Text(" © rithesh_b_rao 2021 ", style: TextStyle(fontSize: 15.0))),
    );
  }

  void navigateToNoteDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  //Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

//Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
          print("------------------> inside updateListView");
          print(noteList.length);
        });
      });
    });
  }

  Widget getAssetImage() {
    AssetImage assetImage = AssetImage('images/note_img.png');
    Image image = Image(
      image: assetImage,
    );
    return Container(
      padding: EdgeInsets.all(30.0),
      child: image,
    );
  }
}
