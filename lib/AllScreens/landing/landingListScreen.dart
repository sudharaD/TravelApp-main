import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'landingEditScreen.dart';
import 'mainViewScreen.dart';

class LandingListScreen extends StatefulWidget {
  static const String idScreen = "LandingListScreen";

  @override
  State<LandingListScreen> createState() => _LandingListScreenState();
}

class _LandingListScreenState extends State<LandingListScreen> {
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
    firestore.collection('main').doc(id).delete();
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
                    print("now location");
                    print(index.toString());
                    print(docs[index]['id']);
                   print(docs[index]['lat']);
                     print(docs[index]['lng']);
                    print("now location");
                    return Padding(

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

                                   fontSize: 25.0,
                                   fontFamily: "Brand Bold",
                                   fontWeight: FontWeight.bold,
                                   color: Colors.blue),
                               textAlign: TextAlign.left,
                             ),
                             SizedBox(
                               height: 5.0,
                             ),
                           Container(
                             margin: EdgeInsets.all(5),
                              child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 10),
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                              decoration: BoxDecoration(
                            //    color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),

                                image: DecorationImage(

                                  image: NetworkImage(docs[index]['pic'].toString()),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Column(
                                children: const [
                                  SizedBox(
                                    height: 10.0,
                                  ),


                                  SizedBox(
                                    height: 5.0,
                                  ),

                                  SizedBox(
                                    height: 10.0,
                                  ),

                                ],
                              ),
                            ),
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
                                                   LandingEditScreen(
                                                       id: docs[index]['id'],
                                                       name: docs[index]
                                                       ['name'],
                                                       district: docs[index]
                                                       ['district'],
                                                       province: docs[index]
                                                       ['province'],
                                                       city: docs[index]
                                                       ['city'],
                                                       nearestTown: docs[index]
                                                       ['nearestTown'],

                                                       dis: docs[index]['dis'],
                                                       lat: docs[index]['lat'],
                                                       lng: docs[index]['lng'],
                                                       pic: docs[index]['pic'],

                                                   ),
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
                             ),

                             Divider(thickness: 5,color: Colors.blue,)
                        ]
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
          title: Text("Main List"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }


}
