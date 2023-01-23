import 'dart:async';
import 'dart:io';

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

class EquipmentScreen extends StatefulWidget {
  static const String idScreen = "EquipmentScreen";

  @override
  _EquipmentScreen createState() => _EquipmentScreen();
}

class _EquipmentScreen extends State<EquipmentScreen> {
  File? _imageFile = null,_imageFile1 = null;
  bool _loading = false;
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String lat="",lng="";
  String name = "", email = "", imgUrl = "";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();
  TextEditingController provinceTextEditingController = TextEditingController();
  TextEditingController districtTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController nearestTownTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController disTextEditingController = TextEditingController();

  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();

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
    setState(() {
      imgUrl = storage.getItem("pic");
    });
  }

  ImagePicker imagePicker = ImagePicker();
  ImagePicker imagePicker1 = ImagePicker();

  Future<void> _chooseImage() async {
    PickedFile? pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<void> _chooseImage1() async {
    PickedFile? pickedFile = await imagePicker1.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile1 = File(pickedFile!.path);
    });
  }

  void _uploadImage(context) async {
    if (_imageFile != null) {
      setState(() {
        _loading = true;
      });
      imageUpload(_imageFile!);
    } else {
      Fluttertoast.showToast(
        msg: "Choose Image",
      );
    }
  }

  void imageUpload(File img) {
    String imageFileName = DateTime.now().microsecondsSinceEpoch.toString()+Uuid().v1().toString();
    final Reference storageReference =FirebaseStorage.instance.ref().child('Images').child(imageFileName);

    final UploadTask uploadTask = storageReference.putFile(img);

    uploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((imageUrl) {
        //save info to firebase
        print(imageUrl);
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
              "Equipment Rent Shop Registration",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Equipment Title",
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
                    controller: addressTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Address",
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
                    controller: provinceTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Province",
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
                    controller: districtTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "District",
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
                    controller: cityTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "City",
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
                    controller: nearestTownTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Nearest Town",
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
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
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
                          child:  ElevatedButton(
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
                          "Pick a Location",
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
                          "Insert Data",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      if (nameTextEditingController.text.length < 3) {
                        displayToastMessage("name must be atleast 3 characters", context);
                      } else if (addressTextEditingController.text.isEmpty) {
                        displayToastMessage("Address is Required!", context);
                      } else if (provinceTextEditingController.text.isEmpty) {
                        displayToastMessage("Province is Required!", context);
                      } else if (districtTextEditingController.text.isEmpty) {
                        displayToastMessage("District is Required!", context);
                      } else if (cityTextEditingController.text.isEmpty) {
                        displayToastMessage("City is Required!", context);
                      } else if (nearestTownTextEditingController.text.isEmpty) {
                        displayToastMessage("Nearest Town is Required!", context);
                      } else if (emailTextEditingController.text.isEmpty) {
                        displayToastMessage("Email is Required!", context);
                      } else if (!emailTextEditingController.text.contains("@")) {
                        displayToastMessage("Email address is not valid", context);
                      } else if (phoneTextEditingController.text.isEmpty) {
                        displayToastMessage("Phone Number is Required!", context);
                      } else if (disTextEditingController.text.isEmpty) {
                        displayToastMessage("Description is Required!", context);
                      } else if (lat==""&&lng=="") {
                        displayToastMessage("Location is Required!", context);
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
          title: Text("Equipment Rent Shop Registration"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: _loading ? bodyProgress : body));
  }

  void _displayDialog(BuildContext context) {
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
                        setState(() {
                          lat = cameraPosition.target.latitude.toString();
                          lng = cameraPosition.target.longitude.toString();
                          Navigator.of(context).pop();
                        });
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
      await firestore.collection("equipments1").add({
        'name': nameTextEditingController.text,
        'address': addressTextEditingController.text,
        'province': provinceTextEditingController.text,
        'district': districtTextEditingController.text,
        'city': cityTextEditingController.text,
        'nearestTown': nearestTownTextEditingController.text,
        'email': emailTextEditingController.text,
        'phone': phoneTextEditingController.text,
        'dis': disTextEditingController.text,
        'pic': imageUrl,
        'pic1': imageUrl1,
        'lat': lat,
        'lng': lng,
        'userid': storage.getItem("userid")
      }).then((value) =>
      {
        nameTextEditingController.text="",
        addressTextEditingController.text="",
        provinceTextEditingController.text="",
        districtTextEditingController.text="",
        cityTextEditingController.text="",
        nearestTownTextEditingController.text="",
        emailTextEditingController.text="",
        phoneTextEditingController.text="",
        disTextEditingController.text="",
        lat="",
        lng="",
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
      text: 'Data Insert Successful!',
    );
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
