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
import 'package:travel_app/AllScreens/userDashboard.dart';

class ProfileScreen2 extends StatefulWidget {
  static const String idScreen = "profileScreen";

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<ProfileScreen2> {
  File? _imageFile = null;
  bool _loading = false;
  final LocalStorage storage = new LocalStorage('localstorage_app');

  String name = "", email = "", imgUrl = "";

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
      child: Padding(
        padding: EdgeInsets.all(8.0),
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
              height: 1.0,
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
                  TextField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
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
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                      controller: ageTextEditingController,
                      keyboardType: TextInputType.none,
                      readOnly: false,
                      decoration: const InputDecoration(
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
                            selectedNumber: int.parse(
                                ageTextEditingController.text.toString()),
                            onChanged: (value) => setState(() =>
                                ageTextEditingController.text =
                                    value.toString()),
                          )),
                  const SizedBox(
                    height: 1.0,
                  ),
                  TextField(
                    controller: bioTextEditingController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
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
                  const SizedBox(
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
                                child: Text('Profile Picture'),
                              ),
                            ),
                            const SizedBox(
                              height: 90.0,
                            ),
                            Center(
                              child:  ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(24.0),
                                    )
                                ),
                                onPressed: () {
                                  _chooseImage();
                                },
                                 child: const Text(
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
                  const SizedBox(
                    height: 10.0,
                  ),
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
                          "Update Account",
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
                      } else if (bioTextEditingController.text.isEmpty) {
                        displayToastMessage("Bio is Required!", context);
                      } else if (ageTextEditingController.text.isEmpty) {
                        displayToastMessage("Age is Required!", context);
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
                    child: Center(
                      child: Text(
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
          title: Text("Profile"),
        ),
        backgroundColor: Colors.white,
        body: new Container(child: _loading ? bodyProgress : body));
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
