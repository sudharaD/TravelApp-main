import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:travel_app/AllScreens/vehicle/vehicleViewScreen.dart';

class VehicleUserListScreen extends StatefulWidget {
  static const String idScreen = "VehicleUserListScreen";

  @override
  _VehicleUserListScreen createState() => _VehicleUserListScreen();
}

class _VehicleUserListScreen extends State<VehicleUserListScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List docs = [],all_docs = [];

  String name = "", email = "", imgUrl = "";

  Future<List?> dataList() async {
    QuerySnapshot querySnapshot;
    List list = [];
    try {
      querySnapshot = await firestore.collection('vehicles1').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
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
            "id": doc.id,
            "category": doc['category'],
            "seats": doc['seats'],
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
    this.dataList().then(
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
                    searchController.text = "";
                  },
                ),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 5.0),
                )),
          )),
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
                              builder: (context) => VehicleViewScreen(
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
                                pic1: docs[index]['pic1'],
                                seats: docs[index]['seats'],
                                category: docs[index]['category'],
                              ),
                            ));
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 210,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(
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
                                docs[index]['name'].toString(),
                                style: const TextStyle(
                                    fontSize: 25.0,
                                    fontFamily: "Brand Bold",
                                    color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                    docs[index]['city'].toString() ,
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),

                              const SizedBox(
                                height: 5.0,
                              ),

                            ],
                          ),
                        ),
                      ),
                    ));
              }))
    ]));

    return Scaffold(
        appBar: AppBar(
          title: Text("Vehicle List"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }
}
