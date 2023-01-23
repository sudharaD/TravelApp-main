import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/AllScreens/loginScreen.dart';
import 'package:localstorage/localstorage.dart';
import '../Drawer/Drawer.dart';
import 'landing/mainViewScreen.dart';

class UserDashboard extends StatefulWidget {
  static const String idScreen = "UserDashboard";

  @override
  _UserDashboard createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  List docs = [],all_docs = [];

  String name = "", email = "", imgUrl = "";

  Future<List?> hotelsList() async {
    QuerySnapshot querySnapshot;
    List list = [];
    try {
      querySnapshot = await firestore.collection('main').get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs.toList()) {
          Map map = {
            "name": doc['name'],
            "dis": doc['dis'],
            "province": doc['province'],
            "district": doc['district'],
            "city": doc['city'],
            "nearestTown": doc['nearestTown'],
            "lat": doc['lat'],
            "lng": doc['lng'],
            "pic": doc['pic'],
            // "pic1": doc['pic1'],
            "id": doc.id
          };
          list.add(map);
        }
      }
      return list;
    } catch (e) {
      print("sorry no read");
      print(e);
      print("sorry no read");

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
        if (temp['name'].contains(query)||temp['dis'].contains(query)||temp['province'].contains(query)
            ||temp['district'].contains(query)||temp['city'].contains(query)||temp['nearestTown'].contains(query)
        ){
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
  void logout(context) async {

    CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      text: 'Do you want to Logout?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pop(context);
        storage.clear();
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.idScreen, (route) => false);
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(name:name,email:email,imgUrl:imgUrl),
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              textAlign: TextAlign.start,
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
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  hintText: 'Place or City',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width: 5.0),
                  )
              ),
            )
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(top: 5,right: 5),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imgUrl),
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
          child: Column(children: <Widget>[
            SizedBox(height: 10,),
            Expanded(
                child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (BuildContext context, int index) {
                 return  Padding(
                        padding: EdgeInsets.all(8.0),
                      child: Card(
                           shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40), // if you need this
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 3,
                          ),
                        ),
                         child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MainViewScreen(
                                      name: docs[index]['name'],
                                      dis: docs[index]['dis'],
                                      district: docs[index]['district'],
                                      province: docs[index]['province'],
                                      city: docs[index]['city'],
                                      nearestTown: docs[index]['nearestTown'],
                                      pic: docs[index]['pic'],
                                        lat:docs[index]['lat'],
                                        lng:docs[index]['lng']
                                      // pic1: docs[index]['pic1']
                                    ),
                                  ));
                            },
                            child: Column(
                                children: [
                                  Text(
                                    docs[index]['name'].toString(),
                                    style: const TextStyle(
                                        fontSize: 40.0,
                                        fontFamily: "Brand Bold",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(15),
                                    child: CachedNetworkImage(
                                      progressIndicatorBuilder: (context, url, progress) =>
                                          Center(
                                            child: CircularProgressIndicator(
                                              value: progress.progress,
                                            ),
                                          ),
                                      imageUrl: docs[index]['pic'].toString(),
//                                         // NetworkImage(docs[index]['pic'].toString()),
                                    ),
                                  ),

                                ]
                            ),
                          )
                        )
                       )
                      );
                    }
                )
            )
          ]
          )
      )
    );
  }
}
