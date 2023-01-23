import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:travel_app/AllScreens/hotel/hotelViewScreen.dart';

import 'hotelEditScreen.dart';

class HotelListScreen extends StatefulWidget {
  static const String idScreen = "HotelListScreen";

  @override
  _HotelListScreen createState() => _HotelListScreen();
}

class _HotelListScreen extends State<HotelListScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List docs = [],all_docs = [];

  String name = "", email = "", imgUrl = "";

  Future<List?> hotelsList() async {
    QuerySnapshot querySnapshot;
    List list = [];
    try {
      querySnapshot = await firestore.collection('hotels1').get();

      if (querySnapshot.docs.isNotEmpty) {

        for (var doc in querySnapshot.docs.toList()) {
          if(storage.getItem('userType').toString()=="admin") {
             Map map = {

              "name": doc['name'],
              "address": doc['address'],
              "province": doc['province'],
              "district": doc['district'],
              "city": doc['city'],
              "nearestTown": doc['nearestTown'],
              "email": doc['email'],
              "phone": doc['phone'],
              "dis": doc['dis'],
              "lat": doc['lat'],
              "lng": doc['lng'],
              "pic": doc['pic'],
              "pic1": doc['pic1'],
              "id": doc.id
            };
            list.add(map);
          }else{
            print( 'printdata');
            print( storage.getItem("userid").toString());
            print(doc['userid'].toString() );
            print( 'printdata');

         if (doc['userid'].toString() ==storage.getItem("userid").toString()) {
            Map map = {
              "name": doc['name'],
              "address": doc['address'],
              "province": doc['province'],
              "district": doc['district'],
              "city": doc['city'],
              "nearestTown": doc['nearestTown'],
              "email": doc['email'],
              "phone": doc['phone'],
              "dis": doc['dis'],
              "lat": doc['lat'],
              "lng": doc['lng'],
              "pic": doc['pic'],
              "pic1": doc['pic1'],
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
        if (temp['name'].contains(query)||temp['address'].contains(query)||temp['province'].contains(query)
            ||temp['district'].contains(query)||temp['city'].contains(query)||temp['nearestTown'].contains(query)
            ||temp['email'].contains(query)||temp['phone'].contains(query)){
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
    firestore.collection('hotels1').doc(id).delete();
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
                              builder: (context) => HotelViewScreen(
                                  name: docs[index]['name'],
                                  address: docs[index]['address'],
                                  district: docs[index]['district'],
                                  province: docs[index]['province'],
                                  city: docs[index]['city'],
                                  nearestTown: docs[index]['nearestTown'],
                                  email: docs[index]['email'],
                                  phone: docs[index]['phone'],
                                  dis: docs[index]['dis'],
                                  lat: docs[index]['lat'],
                                  lng: docs[index]['lng'],
                                  pic: docs[index]['pic'],
                                  pic1: docs[index]['pic1']),
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
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                docs[index]['name'].toString(),
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
                                docs[index]['address'].toString()  ,
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(
                                height: 5.0,
                              ),

                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                docs[index]['phone'].toString(),
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                docs[index]['email'].toString(),
                                style: const TextStyle(
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
                                                    HotelEditScreen(
                                                        id: docs[index]['id'],
                                                        name: docs[index]
                                                            ['name'],
                                                        address: docs[index]
                                                            ['address'],
                                                        district: docs[index]
                                                            ['district'],
                                                        province: docs[index]
                                                            ['province'],
                                                        city: docs[index]
                                                            ['city'],
                                                        nearestTown: docs[index]
                                                            ['nearestTown'],
                                                        email: docs[index]
                                                            ['email'],
                                                        phone: docs[index]
                                                            ['phone'],
                                                        dis: docs[index]['dis'],
                                                        lat: docs[index]['lat'],
                                                        lng: docs[index]['lng'],
                                                        pic: docs[index]['pic'],
                                                        pic1: docs[index]
                                                            ['pic1']),
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
          title: Text("Hotel List"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }
}
