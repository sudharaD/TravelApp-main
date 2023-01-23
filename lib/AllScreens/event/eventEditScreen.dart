import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:map_picker/map_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'eventListScreen.dart';

class EventEditScreen extends StatefulWidget {
  static const String idScreen = "EventEditScreen";

  final String id,lat,lng,lat1,lng1,m_count,budget,date,duration,des,pic,pic1;
  EventEditScreen({required this.id,required this.lat,required this.lng,required this.lat1,required this.lng1,required this.m_count,required this.budget,required this.date,required this.duration,required this.des,required this.pic,required this.pic1}): super();

  @override
  _EventEditScreen createState() => _EventEditScreen();
}

class _EventEditScreen extends State<EventEditScreen> {
  File? _imageFile = null,_imageFile1 = null;
  bool _loading = false;
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String lat="",lng="",lat1="",lng1="";
  String name = "", email = "", imgUrl = "";

  TextEditingController mCountTextEditingController = TextEditingController();
  TextEditingController budgetTextEditingController = TextEditingController();
  TextEditingController dateTextEditingController = TextEditingController();
  TextEditingController durationTextEditingController = TextEditingController();
  TextEditingController disTextEditingController = TextEditingController();

  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  bool pic1=false,pic2=false;

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(6.887752, 79.918661),
    zoom: 15.000,
  );

  var textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    _download(widget.pic.toString(),widget.pic1.toString());
    setState(() {
      lat = widget.lat;
      lng = widget.lng;
      lat1 = widget.lat1;
      lng1 = widget.lng1;
    });
    mCountTextEditingController.text=widget.m_count.toString();
    budgetTextEditingController.text=widget.budget.toString();
    dateTextEditingController.text=widget.date.toString();
    durationTextEditingController.text=widget.duration.toString();
    disTextEditingController.text=widget.des.toString();
  }

  ImagePicker imagePicker = ImagePicker();
  ImagePicker imagePicker1 = ImagePicker();


  Future<void> _download(String url,String url1) async {
    final response = await http.get(Uri.parse(url));
    final response1 = await http.get(Uri.parse(url1));

    // Get the image name
    final imageName = path.basename(url);
    final imageName1 = path.basename(url1);
    // Get the document directory path
    final appDir = await pathProvider.getApplicationDocumentsDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath = path.join(appDir.path, imageName);
    final localPath1 = path.join(appDir.path, imageName1);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    final imageFile1 = File(localPath1);
    await imageFile1.writeAsBytes(response1.bodyBytes);

    setState(() {
      _imageFile = imageFile;
      _imageFile1 = imageFile1;
    });
  }

  Future<void> _chooseImage() async {
    PickedFile? pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
      pic1 = true;
    });
  }

  Future<void> _chooseImage1() async {
    PickedFile? pickedFile = await imagePicker1.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile1 = File(pickedFile!.path);
      pic2 = true;
    });
  }

  void _uploadImage(context) async {
    if (_imageFile != null) {
      setState(() {
        _loading = true;
      });
      imageUpload();
    } else {
      Fluttertoast.showToast(
        msg: "Choose Image",
      );
    }
  }

  void imageUpload() {
    if(pic1){
      if(pic2){
        String imageFileName = DateTime.now().microsecondsSinceEpoch.toString()+Uuid().v1().toString();
        final Reference storageReference =FirebaseStorage.instance.ref().child('Images').child(imageFileName);

        final UploadTask uploadTask = storageReference.putFile(_imageFile!);

        uploadTask.then((TaskSnapshot taskSnapshot) {
          taskSnapshot.ref.getDownloadURL().then((imageUrl) {
            //save info to firebase
            if(_imageFile1!=null){
              String imageFileName1 = DateTime.now().microsecondsSinceEpoch.toString()+Uuid().v1().toString();
              final Reference storageReference1 =FirebaseStorage.instance.ref().child('Images').child(imageFileName1);

              final UploadTask uploadTask1 = storageReference1.putFile(_imageFile1!);

              uploadTask1.then((TaskSnapshot taskSnapshot1) {
                taskSnapshot1.ref.getDownloadURL().then((imageUrl1) {
                  //save info to firebase
                  insertData(context, imageUrl, imageUrl1);
                });
              }).catchError((error) {
                setState(() {
                  _loading = false;
                });
                Fluttertoast.showToast(
                  msg: error.toString(),
                );
              });
            }else{
              insertData(context, imageUrl, "");
            }
          });
        }).catchError((error) {
          setState(() {
            _loading = false;
          });
          Fluttertoast.showToast(
            msg: error.toString(),
          );
        });
      }else{
        if(_imageFile!=null){
          String imageFileName = DateTime.now().microsecondsSinceEpoch.toString()+Uuid().v1().toString();
          final Reference storageReference =FirebaseStorage.instance.ref().child('Images').child(imageFileName);

          final UploadTask uploadTask = storageReference.putFile(_imageFile!);

          uploadTask.then((TaskSnapshot taskSnapshot) {
            taskSnapshot.ref.getDownloadURL().then((imageUrl) {
              //save info to firebase
              insertData(context, imageUrl , widget.pic1.toString());
            });
          }).catchError((error) {
            setState(() {
              _loading = false;
            });
            Fluttertoast.showToast(
              msg: error.toString(),
            );
          });
        }else{
          insertData(context, widget.pic.toString() , widget.pic1.toString());
        }
      }
    }else{
      if(pic2){
        if(_imageFile1!=null){
          String imageFileName1 = DateTime.now().microsecondsSinceEpoch.toString()+Uuid().v1().toString();
          final Reference storageReference1 =FirebaseStorage.instance.ref().child('Images').child(imageFileName1);

          final UploadTask uploadTask1 = storageReference1.putFile(_imageFile1!);

          uploadTask1.then((TaskSnapshot taskSnapshot1) {
            taskSnapshot1.ref.getDownloadURL().then((imageUrl1) {
              //save info to firebase
              insertData(context, widget.pic.toString() , imageUrl1);
            });
          }).catchError((error) {
            setState(() {
              _loading = false;
            });
            Fluttertoast.showToast(
              msg: error.toString(),
            );
          });
        }else{
          insertData(context, widget.pic.toString() , "");
        }
      }else{
        insertData(context, widget.pic.toString() , widget.pic1.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var body = new SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 35.0,
            ),
            Image(
              image: AssetImage("images/logo.png"),
              width: 150.0,
              height: 150.0,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 1.0,
            ),
            Text(
              "Change Event",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: 20.0,),
                  Text(
                    "Latitude : "+lat,
                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(height: 20.0,),
                  Text(
                    "longitude : "+lng,
                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
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
                          "Pick a Start Location",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      _displayDialog(context,1);
                    },
                  ),
                  SizedBox(height: 20.0,),
                  Text(
                    "Latitude : "+lat1,
                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
                    textAlign: TextAlign.left,
                  ),

                  SizedBox(height: 20.0,),
                  Text(
                    "longitude : "+lng1,
                    style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold"),
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
                          "Pick a Destination Location",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      _displayDialog(context,2);
                    },
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: mCountTextEditingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Expecting Member Count",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: budgetTextEditingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Expected Budget",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: dateTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Departure Date",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                    onTap: () async {
                      final DateTime? pick = await showDatePicker(
                        context: context,
                        initialDate: DateFormat("yyyy-MM-dd").parse(widget.date),
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2025),
                        helpText: "Departure Date",
                        cancelText: "Close",
                        confirmText: "Confirm",
                      );
                      dateTextEditingController.text = DateFormat('yyyy-MM-dd').format(pick!);
                    },
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: durationTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Duration",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: disTextEditingController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  _imageFile == null
                      ? Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text('Picture 1'),
                          ),
                        ),
                        SizedBox(
                          height: 90.0,
                        ),
                        Center(
                          child:  ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(24.0),
                                )
                            ),
                            onPressed: () {
                              _chooseImage();
                            },
                             child: Text(
                              'Choose Image',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),

                          ),
                        ),
                      ]))
                      : GestureDetector(
                       onTap: () {
                      _chooseImage();
                       },
                      child: Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  _imageFile1 == null
                      ? Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Text('Picture 2'),
                          ),
                        ),
                        SizedBox(
                          height: 90.0,
                        ),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(24.0),
                                )
                            ),
                            onPressed: () {
                              _chooseImage1();
                            },
                             child: Text(
                              'Choose Image',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),

                          ),
                        ),
                      ]))
                      : GestureDetector(
                    onTap: () {
                      _chooseImage1();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 250.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(_imageFile1!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                          "Update Event",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      if (lat==""&&lng=="") {
                        displayToastMessage("Start Location is Required!", context);
                      } else if (lat1==""&&lng1=="") {
                        displayToastMessage("Destination Location is Required!", context);
                      } else if (mCountTextEditingController.text.isEmpty) {
                        displayToastMessage("Member Count is Required!", context);
                      } else if (budgetTextEditingController.text.isEmpty) {
                        displayToastMessage("Budget is Required!", context);
                      } else if (dateTextEditingController.text.isEmpty) {
                        displayToastMessage("Date is Required!", context);
                      } else if (durationTextEditingController.text.isEmpty) {
                        displayToastMessage("Duration is Required!", context);
                      } else if (disTextEditingController.text.isEmpty) {
                        displayToastMessage("Description is Required!", context);
                      } else {
                        _uploadImage(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    var bodyProgress = new Container(
      child: new Stack(
        children: <Widget>[
          body,
          new Container(
            alignment: AlignmentDirectional.center,
            decoration: new BoxDecoration(
              color: Colors.white70,
            ),
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: new BorderRadius.circular(10.0)),
              width: 300.0,
              height: 200.0,
              alignment: AlignmentDirectional.center,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Center(
                    child: new SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: new Center(
                      child: new Text(
                        "Plase Wait...",
                        style: new TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text("Update Event"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: _loading ? bodyProgress : body));
  }

  void _displayDialog(BuildContext context,int number) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
            body: Stack(
              alignment: Alignment.topCenter,
              children: [
                MapPicker(
                  // pass icon widget
                  iconWidget: Image(
                    image: AssetImage("images/desticon.png"),
                    width: 50.0,
                    height: 50.0,
                    alignment: Alignment.center,
                  ),
                  //add map picker controller
                  mapPickerController: mapPickerController,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    // hide location button
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    //  camera position
                    initialCameraPosition: cameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onCameraMoveStarted: () {
                      // notify map is moving
                      mapPickerController.mapMoving!();
                      textController.text = "checking ...";
                    },
                    onCameraMove: (cameraPosition) {
                      this.cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      // notify map stopped moving
                      mapPickerController.mapFinishedMoving!();
                      //get address name from camera position
                      List<Placemark> placemarks = await placemarkFromCoordinates(
                        cameraPosition.target.latitude,
                        cameraPosition.target.longitude,
                      );

                      // update the ui with the address
                      textController.text =
                      '${placemarks.first.name}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).viewPadding.top + 20,
                  width: MediaQuery.of(context).size.width - 50,
                  height: 50,
                  child: TextFormField(
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    readOnly: true,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    controller: textController,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 100,
                  right: 100,
                  child: SizedBox(
                      height: 120,
                      child: Column(
                          children: [
                            SizedBox(
                              height: 5.0,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(24.0),
                                  )
                              ),
                              child: Container(
                                height: 35.0,
                                child: Center(
                                  child: Text(
                                    "Confirm",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "Brand Bold",
                                        color: Colors.white),
                                  ),
                                ),
                              ),

                              onPressed: () {
                                if(number==1){
                                  setState(() {
                                    lat = cameraPosition.target.latitude.toString();
                                    lng = cameraPosition.target.longitude.toString();
                                  });
                                }else{
                                  setState(() {
                                    lat1 = cameraPosition.target.latitude.toString();
                                    lng1 = cameraPosition.target.longitude.toString();
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(24.0),
                                  )
                              ),
                              child: Container(
                                height: 35.0,
                                child: Center(
                                  child: Text(
                                    "Close",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: "Brand Bold",
                                        color: Colors.white),
                                  ),
                                ),
                              ),

                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ]
                      )
                  ),
                )
              ],
            ));
      },
    );
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void insertData(BuildContext context, String imageUrl, String imageUrl1) async {
    try {
      await firestore.collection("events").doc(widget.id.toString()).update({
        'lat': lat,
        'lng': lng,
        'lat1': lat1,
        'lng1': lng1,
        'm_count': mCountTextEditingController.text,
        'budget': budgetTextEditingController.text,
        'date': dateTextEditingController.text,
        'duration': durationTextEditingController.text,
        'des': disTextEditingController.text,
        'pic': imageUrl,
        'pic1': imageUrl1,
        'userid': storage.getItem("userid")
      }).then((value) =>
      {
        dateTextEditingController.text="",
        durationTextEditingController.text="",
        mCountTextEditingController.text="",
        budgetTextEditingController.text="",
        disTextEditingController.text="",
        lat="",
        lng="",
        lat1="",
        lng1="",
        _imageFile = null,
        _imageFile1 = null,
        setState(() {
          _loading = false;
        })
      });
    } catch (e) {
      print(e);
    }

    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: 'Data Update Successful!',
    ).then((value) => {
      Navigator.pushNamedAndRemoveUntil(context, EventListScreen.idScreen, (route) => true)
    });
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}