import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:travel_app/AllScreens/loginScreen.dart';
import 'package:travel_app/AllScreens/profileScreen2.dart';
import 'package:travel_app/AllScreens/userDashboard.dart';

class ProfileScreen extends StatefulWidget {
  static const String idScreen = "profileScreen";

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<ProfileScreen> {
  File? _imageFile = null;
  bool _loading = false;
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String name = "", email = "", imgUrl = "";

  String fullname = '';
  String age = '';
  String bio = '';

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    fullname =storage.getItem("name");
    age =storage.getItem("age");
    bio =storage.getItem("bio");

    ageTextEditingController.text = storage.getItem("age");
    nameTextEditingController.text = storage.getItem("name");
    bioTextEditingController.text = storage.getItem("bio");
    setState(() {
      imgUrl=storage.getItem("pic");
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
    if (_imageFile != null) {
      setState(() {
        _loading = true;
      });
      //create a unique file name for image
      String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('Images').child(imageFileName);

      final UploadTask uploadTask = storageReference.putFile(_imageFile!);

      uploadTask.then((TaskSnapshot taskSnapshot) {
        taskSnapshot.ref.getDownloadURL().then((imageUrl) {
          //save info to firebase
          updateUser(context, imageUrl);
        });
      }).catchError((error) {
        setState(() {
          _loading = false;
        });
        Fluttertoast.showToast(
          msg: error.toString(),
        );
      });
    } else {
      updateUser(context, imgUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    var body = SingleChildScrollView(
      child: Center(
      //  padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 35.0,
            ),
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.cyan,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              "Profile Details",
              style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 1.0,
                  ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Full Name : " ,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          fullname ,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      ],

                    ),

                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Age : " ,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        age ,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    ],

                  ),



                  const SizedBox(
                    height: 1.0,
                  ),
                  Center(
                    
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            offset: const Offset(
                              0.0,
                              10.0,
                            ),
                            blurRadius: 10.0,
                            spreadRadius: -6.0,
                          ),
                        ],
                      ),
                      child: Text(
                        bio ,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),


                  const SizedBox(
                    height: 10.0,
                  ),

                  const SizedBox(
                    height: 10.0,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );

    var bodyProgress = Container(
      child: Stack(
        children: <Widget>[
          body,
          Container(
            alignment: AlignmentDirectional.center,
            decoration: const BoxDecoration(
              color: Colors.white70,
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: new BorderRadius.circular(10.0)),
              width: 300.0,
              height: 200.0,
              alignment: AlignmentDirectional.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 7.0,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 25.0),
                    child: const Center(
                      child: Text(
                        "Plase Wait...",
                        style: TextStyle(color: Colors.white),
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
          title: const Text("Profile"),
          actions: [
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
                  child:  Icon(Icons.edit)
                ),
              ),

              onPressed: () {
             //   Navigator.pushNamedAndRemoveUntil(context, ProfileScreen2.idScreen, (route) => true);
             //   Scaffold.of(context).openEndDrawer();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>   ProfileScreen2()),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Container(child: _loading ? bodyProgress : body));
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void updateUser(BuildContext context, String imageUrl) async {
    try {
      await firestore.collection("users").doc(storage.getItem("userid")).update({
        'name': nameTextEditingController.text,
        'age': ageTextEditingController.text,
        'bio': bioTextEditingController.text,
        'pic': imageUrl,
      });
    } catch (e) {
      print(e);
    }

    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      text: 'Details Update Successful!',
    ).then((value) => {
      Navigator.pushNamedAndRemoveUntil(
      context, UserDashboard.idScreen, (route) => true)
    });
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
