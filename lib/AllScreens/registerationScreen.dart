import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/AllScreens/loginScreen.dart';

class RegisterationScreen extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _Registeration createState() => _Registeration();
}

class _Registeration extends State<RegisterationScreen> {
  late final double lat, lng;

  File? _imageFile=null;
  bool _loading = false;

  TextEditingController locationTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
    ageTextEditingController.text = "20";
  }

  initialise() {
    this
        ._determinePosition()
        .then((position) => {
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      }),
    }).then((value) => {
      locationTextEditingController.text ="Latitude : "+lat.toString()+" Longitude : "+lng.toString()
    });
  }

  ImagePicker imagePicker = ImagePicker();

  Future<void> _chooseImage() async {
    PickedFile? pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }


  void _uploadImage(context) {
    if(_imageFile!=null){
      setState(() {
        _loading = true;
      });
      //create a unique file name for image
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      final Reference storageReference =FirebaseStorage.instance.ref().child('Images').child(imageFileName);

      final UploadTask uploadTask = storageReference.putFile(_imageFile!);

      uploadTask.then((TaskSnapshot taskSnapshot) {
        taskSnapshot.ref.getDownloadURL().then((imageUrl) {
          //save info to firebase
          registerNewUser(context,imageUrl);
          print(imageUrl);
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
      displayToastMessage(
          "Choose Image!",
          context);
    }

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
              width: 250.0,
              height: 250.0,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 1.0,
            ),
            Text(
              "Travel App",
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
                      labelText: "Full Name",
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
                      controller: ageTextEditingController,
                      keyboardType: TextInputType.none,
                      readOnly: false,
                      decoration: InputDecoration(
                        labelText: "Your Age",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      onTap: () => showMaterialNumberPicker(
                        context: context,
                        title: 'Pick a Age',
                        maxNumber: 100,
                        minNumber: 18,
                        step: 1,
                        confirmText: 'Confirm',
                        cancelText: 'Cancel',
                        selectedNumber: int.parse(ageTextEditingController.text.toString()),
                        onChanged: (value) => setState(() =>
                        ageTextEditingController.text =
                            value.toString()),
                      )),
                  SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: bioTextEditingController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: "Bio",
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
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
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
                      child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child:
                                Text('Profile Picture'),
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
                          ]
                      )
                  )
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
                    height: 1.0,
                  ),
                  TextField(
                    controller: locationTextEditingController,
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Current Location",
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
                          "Create Account",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                              color: Colors.white),
                        ),
                      ),
                    ),

                    onPressed: () {
                      if (nameTextEditingController.text.length < 3) {
                        displayToastMessage(
                            "name must be atleast 3 characters", context);
                      } else if (!emailTextEditingController.text.contains("@")) {
                        displayToastMessage("Email address is not valid", context);
                      } else if (bioTextEditingController.text.isEmpty) {
                        displayToastMessage(
                            "Bio is Required!", context);
                      } else if (passwordTextEditingController.text.length <
                          6) {
                        displayToastMessage(
                            "Password must be at least 6 characters",
                            context);
                      } else if (ageTextEditingController.text.isEmpty) {
                        displayToastMessage(
                            "Age is Required!", context);
                      } else {
                        _uploadImage(context);
                      }
                    },
                  ),

                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  )
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
              },
              child: Text(
                "Already have an Account? Login Here.",
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
                  borderRadius: new BorderRadius.circular(10.0)
              ),
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
                        style: new TextStyle(
                            color: Colors.white
                        ),
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
        title: Text("Register"),
      ),
      backgroundColor: Colors.white,
      body:new Container(
          child: _loading ? bodyProgress : body
      )
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void registerNewUser(BuildContext context,String imageUrl) async {
    final User? firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) //user created
    {
      try {
        await firestore.collection("users").doc(firebaseUser.uid).set({
          'name': nameTextEditingController.text,
          'age': ageTextEditingController.text,
          'lat': lat,
          'lng': lng,
          'bio': bioTextEditingController.text,
          'pic': imageUrl,
          'email': emailTextEditingController.text,
          'admin': 0,
        });
      } catch (e) {
        print(e);
      }

      displayToastMessage("Account Created Successful!", context);
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.idScreen, (route) => true);
    } else {
      //error occured - display error msg
      Navigator.pop(context);
      displayToastMessage("New user account has not been Created.", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
