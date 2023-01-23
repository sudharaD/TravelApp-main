import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleViewScreen extends StatefulWidget {
  static const String idScreen = "VehicleViewScreen";

  final String name,address,province,district,city,nearestTown,email,phone,dis,lat,lng,pic,pic1,category,seats;
  VehicleViewScreen({required this.name,required this.address,required this.province,required this.district,required this.city,required this.nearestTown,required this.email,required this.phone,required this.dis,required this.lat,required this.lng,required this.pic,required this.pic1,required this.category,required this.seats}): super();

  @override
  _VehicleViewScreen createState() => _VehicleViewScreen();
}

class _VehicleViewScreen extends State<VehicleViewScreen> {
  final LocalStorage storage = new LocalStorage('localstorage_app');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = "", email = "", imgUrl = "";
  bool _hasCallSupport = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
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
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
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
                  widget.name,
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
                  widget.address ,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  widget.dis,
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                    height: 50,
                    child: Stack(
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Center(
                                child:  Text(
                                  widget.phone,
                                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ]
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Ink(
                              decoration: const ShapeDecoration(
                                color: Colors.lightBlue,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                ),
                                iconSize: 30,
                                onPressed: () {
                                  _hasCallSupport?_makePhoneCall(widget.phone):null;
                                  // launch("tel://"+widget.phone);
                                  _hasCallSupport?print( "tel://"+widget.phone):print( "Not Support");
                                },
                              ),
                            ),
                          ],
                        ),


                      ],
                    )
                ),
                SizedBox(
                  height: 10.0,
                ),

                SizedBox(
                  height: 15.0,
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Vehicle Type : "+widget.category,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "No. of Seats : "+widget.seats,
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
                        "View a Location",
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
              ]))
        ],
      ),
    ));

    return Scaffold(
        appBar: AppBar(
          title: Text("Vehicle View"),
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
}
