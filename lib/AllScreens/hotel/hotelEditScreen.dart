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
import 'package:travel_app/AllScreens/hotel/hotelListScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class HotelEditScreen extends StatefulWidget {
  static const String idScreen = "HotelEditScreen";

  final String id,name,address,province,district,city,nearestTown,email,phone,dis,lat,lng,pic,pic1;
  HotelEditScreen({required this.id,required this.name,required this.address,required this.province,required this.district,required this.city,required this.nearestTown,required this.email,required this.phone,required this.dis,required this.lat,required this.lng,required this.pic,required this.pic1}): super();

  @override
  _HotelEditScreen createState() => _HotelEditScreen();
}

class _HotelEditScreen extends State<HotelEditScreen> {
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
  bool pic1=false,pic2=false;

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(6.887752, 79.918661),
    zoom: 15.000,
  );

  var textController = TextEditingController();

  ImagePicker imagePicker = ImagePicker();
  ImagePicker imagePicker1 = ImagePicker();

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
    });
    nameTextEditingController.text=widget.name.toString();
    addressTextEditingController.text=widget.address.toString();
    provinceTextEditingController.text=widget.province.toString();
    districtTextEditingController.text=widget.district.toString();
    cityTextEditingController.text=widget.city.toString();
    nearestTownTextEditingController.text=widget.nearestTown.toString();
    emailTextEditingController.text=widget.email.toString();
    phoneTextEditingController.text=widget.phone.toString();
    disTextEditingController.text=widget.dis.toString();
  }

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
    var body = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 35.0,
            ),
            const Image(
              image: AssetImage("images/logo.png"),
              width: 150.0,
              height: 150.0,
              alignment: Alignment.center,
            ),
            const SizedBox(
              height: 1.0,
            ),
            const Text(
              "Hotel Registration Update",
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
                      labelText: "Hotel Name",
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
                          "Update Data",
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
          title: Text("Hotel Registration Update"),
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
                    const SizedBox(
                      height: 5.0,
                    ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(24.0),
                              )
                          ),
                      child: Container(
                        height: 35.0,
                        child: const Center(
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
                    const SizedBox(
                      height: 5.0,
                    ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(24.0),
                              )
                          ),
                      child: Container(
                        height: 35.0,
                        child: const Center(
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
//0115776128
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void insertData(BuildContext context, String imageUrl, String imageUrl1) async {
    try {
   //   await firestore.collection("hotels1").add({
      await firestore.collection("hotels1").doc(widget.id.toString()).update({
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
      Navigator.pushNamedAndRemoveUntil(context, HotelListScreen.idScreen, (route) => true)
    });
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
