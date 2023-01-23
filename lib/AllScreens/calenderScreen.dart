import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class CalenderScreen extends StatefulWidget {
  static const String idScreen = "CalenderScreen";

  @override
  _CalenderScreen createState() => _CalenderScreen();
}

class _CalenderScreen extends State<CalenderScreen> {
  DateTime? selectedDay;
  List<CleanCalendarEvent>? selectedEvent;
  List docs = [];
  String nwtime = "00:00";
  final LocalStorage storage = new LocalStorage('localstorage_app');

  Future<List?> todoList(String date) async {
    QuerySnapshot querySnapshot;
    List list = [];
    try {
      querySnapshot = await firestore.collection('todo_list').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          if (doc['userid'].toString() ==
              storage.getItem("userid").toString()) {
            if (doc['date'].toString() == date) {
              print(doc['date'].toString());
              Map map = {
                "note": doc['note'],
                "time": doc['time'],
                "id": doc.id
              };
              list.add(map);
            }
          }
        }
      }
      return list;
    } catch (e) {
      print(e);
    }
  }

  final Map<DateTime, List<CleanCalendarEvent>> events = {};
  TextEditingController noteTextEditingController = TextEditingController();
  TextEditingController timeTextEditingController = TextEditingController();

  void _handleData(date) {
    setState(() {
      selectedDay = date;
    });
    todoList(DateFormat('yyyy-MM-dd').format(date)).then((value) => {
          setState(() {
            docs = value!;
          })
        });
  }

  // list refresh
  Future<void> _onRefresh() async {
    docs = [];
    await todoList(DateFormat('yyyy-MM-dd').format(selectedDay!))
        .then((value) => {
              setState(() {
                docs = value!;
              })
            });
  }

  void delete_firestore(String id) {
    firestore.collection('todo_list').doc(id).delete();
  }

  // delete function
  void delete(String id) async {
    // confirmation alert
    CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      text: 'Do you want to Delete?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        this.delete_firestore(id);
        Navigator.pop(context);
        await CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          title: 'Successful',
          text: 'Delete Successful!',
          loopAnimation: false,
        );
        _onRefresh();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    selectedEvent = events[selectedDay] ?? [];
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate); // 2016-01-25
    todoList(formattedDate).then((value) => {
          setState(() {
            selectedDay = now;
            docs = value!;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: SafeArea(
          child: Column(children: [
        Expanded(
            child: Column(children: [
          Container(
            height: 325,
            child: Calendar(
              startOnMonday: true,
              selectedColor: Colors.blue,
              todayColor: Colors.red,
              eventColor: Colors.green,
              eventDoneColor: Colors.amber,
              bottomBarColor: Colors.deepOrange,
              onDateSelected: (date) {
                return _handleData(date);
              },
              events: events,
              isExpanded: true,
              dayOfWeekStyle: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w100,
              ),
              bottomBarTextStyle: const TextStyle(
                color: Colors.black,
              ),
              hideBottomBar: false,
              hideArrows: false,
              weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            ),
          ),
          Expanded(
              child: Container(
                  child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Card(
                                        child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            docs[index]['time'].toString(),
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Brand Bold"),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 100,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            docs[index]['note'].toString(),
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Brand Bold"),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 100,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text("Edit",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    _displayDialogs(
                                                        context,
                                                        docs[index]['note']
                                                            .toString(),
                                                        docs[index]['time']
                                                            .toString(),
                                                        docs[index]['id']
                                                            .toString());
                                                  }),
                                              GestureDetector(
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.delete,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text("Delete",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    delete(docs[index]['id']
                                                        .toString());
                                                  })
                                            ],
                                          ),
                                        ],
                                      ),
                                    )))));
                      })))
        ])),
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedDay == null) {
            displayToastMessage("Select Date!", context);
          } else {
            _displayDialog(context);
          }
        },
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _displayDialog(BuildContext context) {
    noteTextEditingController.text = "";
    timeTextEditingController.text = "";
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          body: SingleChildScrollView(
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(20.0),
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    SizedBox(
                      height: 35.0,
                    ),
                    const Image(
                      image: AssetImage("images/logo.png"),
                      width: 150.0,
                      height: 150.0,
                      alignment: Alignment.center,
                    ),
                    const SizedBox(
                      height: 1.0,
                    ),
                    const Text(
                      "Add To-Do List",
                      style:
                          TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 1.0,
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(selectedDay!),
                      style:
                          TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            TextField(
                              controller: noteTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Note",
                                labelStyle: TextStyle(
                                  fontSize: 14.0,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            TextField(
                              enabled: false,
                              controller: timeTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Time",
                                labelStyle: TextStyle(
                                  fontSize: 14.0,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            GestureDetector(
                              child: Center(
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                     child: Center(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                      children:   [
                                       Icon(
                                        Icons.alarm_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                       SizedBox(width: 5),
                                       Text("set time",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  )),
                                )),
                                onTap: () {
                                  _scheduleOneShotAlarm();
                                  //  this.delete(docs[index]['id'].toString());
                                }),
                            const SizedBox(
                              height: 30.0,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(24.0),
                                  )),
                              child: Container(
                                height: 50.0,
                                child: const Center(
                                  child: Text(
                                    "Add Note",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand Bold",
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (noteTextEditingController.text.isEmpty) {
                                  displayToastMessage(
                                      "Note is Required!", context);
                                } else {
                                  insertData(context);
                                }
                              },
                            )
                          ],
                        ))
                  ]))),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              noteTextEditingController.text = "";
              timeTextEditingController.text = "";
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
          //     floatingActionButtonLocation:nokey? FloatingActionButtonLocation.centerFloat:null,
        );
      },
    );
  }

  ///////////////////////////////////////////
  Future<TimeOfDay> _chooseDate() async {
    TimeOfDay? chosenDate = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (chosenDate != null) {
      return chosenDate;
    }
    return TimeOfDay.now();
  }

  void _scheduleOneShotAlarm() async {
    TimeOfDay chosenDate = await _chooseDate();
    String ptime = "Time Set @ " +
        chosenDate.hour.toString() +
        ":" +
        chosenDate.minute.toString();
    if (chosenDate.minute < 10) {
      nwtime = chosenDate.hour.toString() + ":0" + chosenDate.minute.toString();
    } else {
      nwtime = chosenDate.hour.toString() + ":" + chosenDate.minute.toString();
    }
    timeTextEditingController.text = nwtime;
    displayToastMessage(ptime, context);
    print(chosenDate.hour);
    print(chosenDate.minute);
  }

  ////////////////////////////////////////////////////

  void _displayDialogs(
      BuildContext context, String exdata, String extime, String exid) {
    noteTextEditingController.text = exdata;
    timeTextEditingController.text = extime;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          body: SingleChildScrollView(
              child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(20.0),
                  padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    SizedBox(
                      height: 35.0,
                    ),
                    Image(
                      image: AssetImage("images/logo.png"),
                      width: 150.0,
                      height: 150.0,
                      alignment: Alignment.center,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    Text(
                      "Edit To-Do List",
                      style:
                          TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(selectedDay!),
                      style:
                          TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            TextField(
                              controller: noteTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Note",
                                labelStyle: TextStyle(
                                  fontSize: 14.0,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            TextField(
                              enabled: false,
                              controller: timeTextEditingController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Time",
                                labelStyle: TextStyle(
                                  fontSize: 14.0,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10.0,
                                ),
                              ),
                              style: TextStyle(fontSize: 14.0),
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.alarm_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text("set time",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _scheduleOneShotAlarm();
                                  //  this.delete(docs[index]['id'].toString());
                                }),
                            const SizedBox(
                              height: 30.0,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(24.0),
                                  )),
                              child: Container(
                                height: 50.0,
                                child: const Center(
                                  child: Text(
                                    "Edit Note",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Brand Bold",
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (noteTextEditingController.text.isEmpty) {
                                  displayToastMessage(
                                      "Note is Required!", context);
                                } else {
                                  insertDatas(context, exid);
                                }
                              },
                            )
                          ],
                        ))
                  ]))),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              noteTextEditingController.text = "";
              timeTextEditingController.text = "";
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
          //  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void insertDatas(BuildContext context, String idnumber) async {
    try {
      await firestore.collection("todo_list").doc(idnumber).update({
        'note': noteTextEditingController.text,
        'date': DateFormat('yyyy-MM-dd').format(selectedDay!),
        'time': nwtime,
        'userid': storage.getItem("userid")
      }).then((value) => {
            noteTextEditingController.text = "",
            timeTextEditingController.text = "",
            CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              text: 'Note Saved Successful!',
            ).then((value) => {Navigator.of(context).pop()})
          });
      _onRefresh();
    } catch (e) {
      print(e);
    }
  }

  void insertData(BuildContext context) async {
    try {
      await firestore.collection("todo_list").add({
        'note': noteTextEditingController.text,
        'date': DateFormat('yyyy-MM-dd').format(selectedDay!),
        'time': nwtime,
        'userid': storage.getItem("userid")
      }).then((value) => {
            noteTextEditingController.text = "",
            timeTextEditingController.text = "",
            CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              text: 'Note Saved Successful!',
            ).then((value) => {Navigator.of(context).pop()})
          });
      _onRefresh();
    } catch (e) {
      print(e);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
