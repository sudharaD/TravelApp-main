import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'eventEditScreen.dart';
import 'eventViewScreen.dart';

class EventListScreen extends StatefulWidget {
  static const String idScreen = "EventListScreen";

  @override
  _EventListScreen createState() => _EventListScreen();
}

class _EventListScreen extends State<EventListScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List docs = [],all_docs = [];

  String name = "", email = "", imgUrl = "";

  Future<List?> hotelsList() async {
    QuerySnapshot querySnapshot;
    List list = [];
    try {
      querySnapshot = await firestore.collection('events').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          if(storage.getItem('userType').toString()=="admin") {

               Map map = {
                "lat": doc['lat'],
                "lng": doc['lng'],
                "lat1": doc['lat1'],
                "lng1": doc['lng1'],
                "m_count": doc['m_count'],
                "budget": doc['budget'],
                "date": doc['date'],
                "duration": doc['duration'],
                "des": doc['des'],
                "pic": doc['pic'],
                "pic1": doc['pic1'],
                "userid": doc['userid'],
                "id": doc.id
              };
              list.add(map);

          }else{
            if (doc['userid'].toString() == storage.getItem("userid").toString()) {
              Map map = {
                "lat": doc['lat'],
                "lng": doc['lng'],
                "lat1": doc['lat1'],
                "lng1": doc['lng1'],
                "m_count": doc['m_count'],
                "budget": doc['budget'],
                "date": doc['date'],
                "duration": doc['duration'],
                "des": doc['des'],
                "pic": doc['pic'],
                "pic1": doc['pic1'],
                "userid": doc['userid'],
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    setState(() {
      name = storage.getItem('name');
      email = storage.getItem('email');
      imgUrl = storage.getItem('pic');
    });
    this.hotelsList().then(
      (value) => {
        setState(() {
          docs = value!;
          all_docs = value;
        })
    });
  }

  void filterSearchResults(String query) {
    List temp_list=[];
    if(query.isNotEmpty) {
      for (var temp in all_docs) {
        if (temp['m_count'].contains(query)||temp['budget'].contains(query)||temp['date'].contains(query) ||temp['des'].contains(query)){
          temp_list.add(temp);
        }
      }
      setState(() {
        docs = temp_list;
      });
    }else{
      setState(() {
        docs = all_docs;
      });
    }
  }

  // list refresh
  Future<void> _onRefresh() async {
    docs = [];
    await this.hotelsList().then((value) => {
          setState(() {
            docs = value!;
          })
        });
  }

  void delete_firestore(String id) {
    firestore.collection('events').doc(id).delete();
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
  Widget build(BuildContext context) {
    var body = Container(
        child: Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          onChanged: (value) {
            filterSearchResults(value);
          },
          controller: searchController,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  filterSearchResults("");
                  searchController.text="";
                },
              ),
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue,
                    width: 5.0),
              )
          ),
        )
      ),
      Expanded(
          child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventViewScreen(
                                  id: docs[index]['id'],
                                  lat: docs[index]['lat'],
                                  lng: docs[index]['lng'],
                                  lat1: docs[index]['lat1'],
                                  lng1: docs[index]['lng1'],
                                  m_count: docs[index]['m_count'],
                                  budget: docs[index]['budget'],
                                  date: docs[index]['date'],
                                  duration: docs[index]['duration'],
                                  des: docs[index]['des'],
                                  pic: docs[index]['pic'],
                                  pic1: docs[index]['pic1'],
                                  userid: docs[index]['userid']),
                            ));
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: Offset(
                                  0.0,
                                  10.0,
                                ),
                                blurRadius: 10.0,
                                spreadRadius: -6.0,
                              ),
                            ],
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.multiply,
                              ),
                              image:
                                  NetworkImage(docs[index]['pic'].toString()),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                "Budget Rs."+docs[index]['budget'].toString(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Brand Bold",
                                    color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Event Date : "+docs[index]['date'].toString(),
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                docs[index]['des'].toString(),

                                style: TextStyle(

                                    fontSize: 12.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                "Time Duration : "+docs[index]['duration'].toString(),
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Member Maximum : "+docs[index]['m_count'].toString(),
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              Align(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 5),
                                              Text("Edit",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EventEditScreen(
                                                      id: docs[index]['id'],
                                                      lat: docs[index]['lat'],
                                                      lng: docs[index]['lng'],
                                                      lat1: docs[index]['lat1'],
                                                      lng1: docs[index]['lng1'],
                                                      m_count: docs[index]['m_count'],
                                                      budget: docs[index]['budget'],
                                                      date: docs[index]['date'],
                                                      duration: docs[index]['duration'],
                                                      des: docs[index]['des'],
                                                      pic: docs[index]['pic'],
                                                      pic1: docs[index]['pic1']),
                                              ));
                                        }),
                                    GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          margin: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 5),
                                              Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          this.delete(
                                              docs[index]['id'].toString());
                                        })
                                  ],
                                ),
                                alignment: Alignment.bottomLeft,
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                );
              }
            )
          )
        ]
      )
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Events List"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }
}
