import 'dart:io';
import 'package:skt_app/database/database.dart';
import 'package:skt_app/models/note_model.dart';
import 'package:skt_app/screens/add_note_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  //const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");

  DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    _noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget _buildNote(Note note) {
    print("resimpath - " + note.picPath!);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AddNoteScreen(
                  updateNoteList: _updateNoteList(),
                  note: note,
                ),
              ),
            ),
            child: Container(
              //width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                //color: AppTheme.of(context).secondaryBackground,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x3600000F),
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: note.picPath! == ""
                                ? Image.asset("images/noPic.jpg")
                                : Image.file(
                                    File(note.picPath!),
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(4, 4, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(25, 4, 0, 0),
                              child: Text(note.title!,
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(25, 4, 0, 0),
                            child: Text(
                              _dateFormatter.format(note.date!),
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 5.0,
            color: Colors.black38,
            thickness: 2.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.amber,
            centerTitle: true,
            title: Text(
              "YOUR FOODS",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.purple),
            )),
        backgroundColor: Colors.amberAccent[100],
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => AddNoteScreen(
                    updateNoteList: _updateNoteList,
                  ),
                ));
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
            future: _noteList,
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final int completedNoteCount = snapshot.data!
                  .where((Note note) => note.status == 1)
                  .toList()
                  .length;

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 80.0),
                itemCount: int.parse(snapshot.data!.length.toString()),
                itemBuilder: (BuildContext context, int index) {
                  return _buildNote(snapshot.data![index]);
                },
              );
            }));
  }
}
