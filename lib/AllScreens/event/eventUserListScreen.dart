import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'eventUserViewScreen.dart';

class EventUserListScreen extends StatefulWidget {
  static const String idScreen = "EventUserListScreen";

  @override
  _EventUserListScreen createState() => _EventUserListScreen();
}

class _EventUserListScreen extends State<EventUserListScreen> {
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
                              builder: (context) => EventUserViewScreen(
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
                          height: 180,
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
                              SizedBox(
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
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                docs[index]['des'].toString(),
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
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
