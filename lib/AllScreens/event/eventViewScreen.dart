import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';

class EventViewScreen extends StatefulWidget {
  static const String idScreen = "EventViewScreen";

  final String id,lat,lng,lat1,lng1,m_count,budget,date,duration,des,pic,pic1,userid;
  EventViewScreen({required this.id,required this.lat,required this.lng,required this.lat1,required this.lng1,required this.m_count,required this.budget,required this.date,required this.duration,required this.des,required this.pic,required this.pic1,required this.userid}): super();

  @override
  _EventViewScreen createState() => _EventViewScreen();
}

class _EventViewScreen extends State<EventViewScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = "", email = "", imgUrl = "";

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<MarkerId, Marker> markers1 = <MarkerId, Marker>{};

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
    setState(() {
      loc(double.parse(widget.lat), double.parse(widget.lng), '1');
      loc(double.parse(widget.lat1), double.parse(widget.lng1), '2');
    });
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
              ]))
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
            ));
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
