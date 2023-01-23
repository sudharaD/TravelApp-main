import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';

import '../chat/message.dart';

class EventUserViewScreen extends StatefulWidget {
  static const String idScreen = "EventUserViewScreen";

  final String id,lat,lng,lat1,lng1,m_count,budget,date,duration,des,pic,pic1,userid;
  EventUserViewScreen({required this.id,required this.lat,required this.lng,required this.lat1,required this.lng1,required this.m_count,required this.budget,required this.date,required this.duration,required this.des,required this.pic,required this.pic1,required this.userid}): super();

  @override
  _EventUserViewScreen createState() => _EventUserViewScreen();
}

class _EventUserViewScreen extends State<EventUserViewScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController message = new TextEditingController();

  String name = "", email = "", imgUrl = "";
  int members=0;
  bool member_in_available=true;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> markers1 = <MarkerId, Marker>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    event_count();
    setState(() {
      name = storage.getItem('name');
      email = storage.getItem('email');
      imgUrl = storage.getItem('pic');
    });
    setState(() {
      loc(double.parse(widget.lat), double.parse(widget.lng), '1');
      loc(double.parse(widget.lat1), double.parse(widget.lng1), '2');
    });
  }

  void event_count() async{
    try {
      await firestore.collection('events').doc(widget.id.toString()).collection("members").get().then((value) =>
      {
        setState(() {
          members=value.size;
        })
      });
      await firestore.collection('events').doc(widget.id.toString()).collection("members").doc(storage.getItem('userid')).get().then((value) => {
        if(value.data()!=null){
          setState((){
            member_in_available=false;
          })
        }else{
          setState((){
            member_in_available=true;
          })
        }
      });

    } catch (e) {
      print(e);
    }
  }

  void joinEvent(String id) async{
    await firestore.collection("events").doc(widget.id.toString()).collection("members").doc(id).set({
      'm_id':id
    });
    event_count();
  }

  void loc(latitude, longitude, id) {LatLng latlng = LatLng(latitude, longitude);
    final Marker marker = Marker(
      markerId: MarkerId(id),
      position: latlng,
      icon: BitmapDescriptor.defaultMarker,
      draggable: false,
      zIndex: 1,
    );
    if(id=="1") {
      setState(() {
        markers[MarkerId(id)] = marker;
      });
    }else{
      setState(() {
        markers1[MarkerId(id)] = marker;
      });
    }
  }
  
  void delete_firestore() {
    firestore.collection('events').doc(widget.id.toString()).collection("members").doc(storage.getItem('userid')).delete();
  }

  // delete function
  void delete() async {
    // confirmation alert
    CoolAlert.show(
      context: context,
      type: CoolAlertType.confirm,
      text: 'Do you want to Leave This Event?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        this.delete_firestore();
        Navigator.pop(context);
        await CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          title: 'Successful',
          text: 'Event Leave Successful!',
          loopAnimation: false,
        ).then((value) => {
          event_count()
        });
      },
    );
  }

  void _displayChat(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
            padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: messages(
                      email: email,
                      id: widget.id.toString()
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: message,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black12,
                            hintText: 'Type a message...',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 8.0),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(50),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: new BorderRadius.circular(50),
                            ),
                          ),
                          validator: (value) {},
                          onSaved: (value) {
                            message.text = value!;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (message.text.isNotEmpty) {
                            firestore.collection("events").doc(widget.id.toString()).collection('messages').doc().set({
                              'message': message.text.trim(),
                              'time': DateTime.now(),
                              'date_time': DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now()).toString(),
                              'email': email,
                              'name':storage.getItem('name')
                            });

                            message.clear();
                          }
                        },
                        icon: Icon(Icons.send_sharp),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var body = SingleChildScrollView(
        child: Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(
                      0.0,
                      10.0,
                    ),
                    blurRadius: 10.0,
                    spreadRadius: -6.0,
                  ),
                ],
              ),
              child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 2.0,
                  ),
                  items: [
                    Container(
                      child: Container(
                        margin: EdgeInsets.all(5.0),
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            child: Stack(
                              children: <Widget>[
                                Image.network(
                                    widget.pic.toString(),
                                    fit: BoxFit.cover,
                                    width: 1000.0),
                                Positioned(
                                  bottom: 0.0,
                                  left: 0.0,
                                  right: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromARGB(200, 0, 0, 0),
                                          Color.fromARGB(0, 0, 0, 0)
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                    if(widget.pic1.toString() != "") ...[
                      Container(
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: ClipRRect(
                              borderRadius:
                              BorderRadius.all(Radius.circular(5.0)),
                              child: Stack(
                                children: <Widget>[
                                  Image.network(
                                      widget.pic1.toString(),
                                      fit: BoxFit.cover,
                                      width: 1000.0),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(200, 0, 0, 0),
                                            Color.fromARGB(0, 0, 0, 0)
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                      )
                    ]
                  ]
              )
          ),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Budget Rs. "+widget.budget,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontFamily: "Brand Bold",
                      color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Event Date : "+widget.date,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  widget.des,
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Time Duration :"+widget.duration,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Member Maximum : "+widget.m_count,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  "Available : "+members.toString()+" / "+widget.m_count,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      )
                  ),
                  child: Container(
                    height: 50.0,
                    child: Center(
                      child: Text(
                        "View a Start Location",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Brand Bold",
                            color: Colors.white),
                      ),
                    ),
                  ),

                  onPressed: () {
                    _displayDialog(context);
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      )
                  ),
                  child: Container(
                    height: 50.0,
                    child: Center(
                      child: Text(
                        "View a Destination Location",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Brand Bold",
                            color: Colors.white),
                      ),
                    ),
                  ),

                  onPressed: () {
                    _displayDialog1(context);
                  },
                ),
                if(widget.userid==storage.getItem('userid')) ...[
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(24.0),
                        )
                    ),
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Open Chat",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      _displayChat(context);
                    },
                  ),
                ] else if(members<int.parse(widget.m_count)) ...[
                  if(member_in_available) ...[
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          )
                      ),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Join Event",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),

                      onPressed: () {
                        joinEvent(storage.getItem('userid'));
                      },
                    )
                  ] else ...[
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          )
                      ),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Open Chat",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),

                      onPressed: () {
                        _displayChat(context);
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          )
                      ),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Leave Event",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),

                      onPressed: () {
                        delete();
                      },
                    )
                  ]
                ]
              ]
              )
          )
        ],
      ),
    ));

    return Scaffold(
        appBar: AppBar(
          title: Text("Event View"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }

  void _displayDialog(BuildContext context) {
    CameraUpdate cameraUpdate= CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(double.parse(widget.lat),double.parse(widget.lng)),
      zoom: 10.000,
    ));
    GoogleMapController mapController;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    mapController.animateCamera(cameraUpdate);
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  // hide location button
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  //  camera position
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(widget.lat),double.parse(widget.lng)),
                    zoom: 10.000,
                  ),
                  markers: Set<Marker>.of(markers.values),
                )
              ],
            )
        );
      },
    );
  }

  void _displayDialog1(BuildContext context) {
    CameraUpdate cameraUpdate= CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(double.parse(widget.lat1),double.parse(widget.lng1)),
      zoom: 10.000,
    ));
    GoogleMapController mapController;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    mapController.animateCamera(cameraUpdate);
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  // hide location button
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  //  camera position
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(widget.lat1),double.parse(widget.lng1)),
                    zoom: 10.000,
                  ),
                  markers: Set<Marker>.of(markers1.values),
                )
              ],
            ));
      },
    );
  }
}
