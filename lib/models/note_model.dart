class Note {
  int? id;
  String? title;
  DateTime? date;
  int? status;
  String? picPath;

  Note({this.title, this.date, this.status, this.picPath});

  Note.withId({this.id, this.title, this.date, this.status, this.picPath});

  ///to map
  ///
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();

    if (id != null) {
      map["id"] = id;
    }
    map["title"] = title;
    map["date"] = date!.toIso8601String();
    map["status"] = status; /////////
    map["picPath"] = picPath;
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
        id: map["id"],
        title: map["title"],
        date: DateTime.parse(map["date"]),
        status: map["status"],
        picPath: map["picPath"]);
  }
}
