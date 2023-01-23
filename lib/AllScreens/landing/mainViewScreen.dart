import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';

import '../accomadation.dart';

class MainViewScreen extends StatefulWidget {
  static const String idScreen = "MainViewScreen";

  final String name,dis,province,district,city,nearestTown,pic,lat,lng;
  MainViewScreen({required this.name,required this.dis,required this.province,required this.district,required this.city,required this.nearestTown ,required this.pic ,required this.lat,required this.lng }): super();

  @override
  State<MainViewScreen> createState() => _MainViewScreenState();
}

class _MainViewScreenState extends State<MainViewScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = "", email = "", imgUrl = "";

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

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
       loc(double.parse(widget.lat), double.parse(widget.lng), 'id');
    });
  }

  void loc(latitude, longitude, id) {
    LatLng latlng = LatLng(latitude, longitude);
    final Marker marker = Marker(
      markerId: MarkerId(id),
      position: latlng,
      icon: BitmapDescriptor.defaultMarker,
      draggable: false,
      zIndex: 1,
    );
    setState(() {
      markers[MarkerId(id)] = marker;
    });
  }

  bool dismodel = true;
  @override
  Widget build(BuildContext context) {
    var body = SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Text(
                widget.name,
                style: TextStyle(
                    fontSize: 24.0,
                    fontFamily: "Brand Bold",
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 10.0,
              ),
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
                  child: Image.network(
                      widget.pic.toString(),
                      fit: BoxFit.cover,
                      width: 1000.0),
              ),

              dismodel?
             Padding(
               padding: EdgeInsets.all(20.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                 children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: const [
                        Text(
                          "Province",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Brand Bold",
                              color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "District",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Brand Bold",
                              color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "City",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Brand Bold",
                              color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "Nearest Town",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Brand Bold",
                              color: Colors.black),
                          textAlign: TextAlign.left,
                        ),
                    ]
                  ),
                   Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.max,
                       children: const [
                         Text(
                           " - ",
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                         Text(
                           " - ",
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                         Text(
                           " - ",
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                         Text(
                           " - ",
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                       ]
                   ),
                   Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.max,
                       children: [
                         Text(
                           widget.province,
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.right,
                         ),
                         Text(
                           widget.district,
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.right,
                         ),
                         Text(
                           widget.city,
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                         Text(
                           widget.nearestTown,
                           style: TextStyle(
                               fontSize: 14.0,
                               fontFamily: "Brand Bold",
                               color: Colors.black),
                           textAlign: TextAlign.left,
                         ),
                       ]
                   )
              ],
                )
            ):
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                     children: [
                      Text(
                        "Province - ",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.province,
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      ),

                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                     children: [
                      const Text(
                        "District - ",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.district,
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(

                    children: [
                      const Text(
                        "City - ",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.city,
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(

                    mainAxisSize: MainAxisSize.max,
                     children: [
                      const Text(
                        "Nearest Town - ",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.nearestTown,
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontFamily: "Brand Bold",
                            color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),


                  ]
                )
                 ),
              const Text(
                 "Description",
                style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: "Brand Bold",
                    color: Colors.black),
                textAlign: TextAlign.left,
              ),
              Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(children: [

                    const SizedBox(
                      height: 10.0,
                    ),

                    Text(
                      widget.dis,
                      style: TextStyle(fontSize: 18.0, color: Colors.black),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 100,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),
                    widget.lat.contains('0.00')?
                    const SizedBox(
                      height: 10.0,
                    ):
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          )
                      ),
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            "View in Map",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),

                      onPressed: () {
                       //  Navigator.pushNamedAndRemoveUntil(context, Accomadation.idScreen, (route) => true);
                        if(widget.lat.contains('0.00')){
                          displayToastMessage( 'Map Location Not Found',context);
                        }else {
                          _displayDialog(context);
                        }
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
                        child: const Center(
                          child: Text(
                            "View a Accomadation",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand Bold",
                                color: Colors.white),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, Accomadation.idScreen, (route) => true);
                        // _displayDialog(context);
                      },
                    ),
                  ]))
            ],
          ),
        ));

    return Scaffold(
        appBar: AppBar(
          title: Text("Main View"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: body));
  }

  void _displayDialog(BuildContext context) {
    CameraUpdate cameraUpdate= CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(double.parse(widget.lat),double.parse(widget.lng)),
      //      target: LatLng(7.058227,79.885107),
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

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
