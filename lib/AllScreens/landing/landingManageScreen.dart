import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../../Drawer/Drawer.dart';
import 'landingListScreen.dart';
import 'landingScreen.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "MainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final LocalStorage storage = new LocalStorage('localstorage_app');

  String name="",email="",imgUrl="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }

  initialise() {
    setState(() {
      name=storage.getItem('name');
      email=storage.getItem('email');
      imgUrl=storage.getItem('pic');
    });
    print(imgUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(name:name,email:email,imgUrl:imgUrl),
      appBar: AppBar(
        title: Text("Main Screen Managment"),
        actions: [
          Container(
            padding: EdgeInsets.only(top: 5,right: 5),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imgUrl),
                )
              ],
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(

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
                height: 10.0,
              ),
              Text(
                "Main Screen Management",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30.0,
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
                            "Add New",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, LandingScreen.idScreen, (route) => true);
                      },
                    ),
                    SizedBox(
                      height: 30.0,
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
                            "Main Screen List",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, LandingListScreen.idScreen, (route) => true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
