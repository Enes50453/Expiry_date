import 'dart:convert';
import 'dart:io';
import 'package:skt_app/database/database.dart';
import 'package:skt_app/models/note_model.dart';
import 'package:skt_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';

class AddNoteScreen extends StatefulWidget {
  //const AddNoteScreen({super.key});
  final Note? note;
  final Function? updateNoteList;

  AddNoteScreen({this.note, this.updateNoteList});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _priority = "Low";
  String _picPath = "";
  DateTime _date = DateTime.now();
  String btnText = "URUN EKLE";
  String titleText = "URUN EKLE";

  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat("MMM dd, yyy");

  final List<String> _priorities = ["Low", "Medium", "High"];

  File? image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _priority = widget.note!.priority!;
      _picPath = widget.note!.picPath!;

      setState(() {
        btnText = "URUN GUNCELLE";
        titleText = "URUN GUNCELLE";
      });
    } else {
      setState(() {
        btnText = "URUN EKLE";
        titleText = "URUN EKLE";
      });
    }

    _dateController.text = _dateFormatter.format(_date);

    ///show todays date.
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    ////////******** */
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date); //////////
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(),
      ),
    );

    widget.updateNoteList!();
  }

  _submit() {
    //////////
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print("$_title, $_date, $_priority");

      Note note = Note(
          title: _title, date: _date, priority: _priority, picPath: _picPath);

      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      }

      widget.updateNoteList!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => HomeScreen())),
                  child: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  titleText,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Container(
                          child: image == null
                              ? Stack(children: [
                                  Image.asset("images/noPic.jpg"),
                                  Positioned(
                                    bottom: 2,
                                    right: 8,
                                    child: IconButton(
                                      onPressed: () => onImageButtonPressed(
                                          ImageSource.camera),
                                      icon: Icon(Icons.camera_alt),
                                      color: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 42,
                                    child: IconButton(
                                      onPressed: () => onImageButtonPressed(
                                          ImageSource.gallery),
                                      icon: Icon(Icons.search),
                                      color: Colors.white,
                                    ),
                                  )
                                ])
                              : Image.file(image!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: "URUN ADI",
                            labelStyle: TextStyle(fontSize: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? "Please enter a note title"
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title, /////////
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          onTap: _handleDatePicker, ////open date picker
                          decoration: InputDecoration(
                            labelText: "SKT",
                            labelStyle: TextStyle(fontSize: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: "ONCELIK",
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) =>
                              _priority == null ? "LUTFEN SECINIZ" : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                          value: _priority,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: ElevatedButton(
                          child: Text(
                            btnText,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: _submit,
                        ),
                      ),
                      widget.note != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ElevatedButton(
                                child: Text(
                                  "URUN SIL",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onImageButtonPressed(ImageSource source) async {
    try {
      await getImage(source);
      GallerySaver.saveImage(image!.path);
      print(image!.path.toString());
      _picPath = image!.path.toString();
    } catch (e) {
      print(e);
    }
  }

  Future getImage(ImageSource source) async {
    final PickedFile = await picker.pickImage(source: source);
    setState(() {
      image = File(PickedFile!.path);
    });
  }
}
