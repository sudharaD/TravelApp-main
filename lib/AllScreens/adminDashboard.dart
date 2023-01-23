import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:travel_app/AllScreens/equipment/equipmentManageScreen.dart';
import 'package:travel_app/AllScreens/hotel/hotelManageScreen.dart';
import 'package:travel_app/AllScreens/vehicle/vehicleManageScreen.dart';

import '../Drawer/Drawer.dart';
import 'event/eventManageScreen.dart';
import 'landing/landingManageScreen.dart';

class AdminDashboard extends StatefulWidget {
  static const String idScreen = "AdminDashboard";

  @override
  _AdminDashboard createState() => _AdminDashboard();
}

class _AdminDashboard extends State<AdminDashboard> {
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
        title: Text("Admin Dashboard"),
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
              const SizedBox(
                height: 35.0,
              ),
              const Image(
                image: AssetImage("images/logo.png"),
                width: 250.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 10.0,
              ),

              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [

                    storage.getItem('userType').toString()=="admin"?   const SizedBox(
                      height: 30.0,
                    ):  const SizedBox(
                      height: 0.0,
                    ),
                    storage.getItem('userType').toString()=="admin"? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0),)
                      ),
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            "Main Screen Management",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => true);
                      },
                    ): const SizedBox(
                      height: 0.0,
                    ),
                    storage.getItem('userType').toString()=="admin"?   const SizedBox(
                      height: 30.0,
                    ):  const SizedBox(
                      height: 0.0,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(24.0),)
                      ),
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            "Hotel Management",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, HotelManageScreen.idScreen, (route) => true);
                      },
                    ),
                    const SizedBox(
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
                            "Vehicle Management",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, VehicleManageScreen.idScreen, (route) => true);
                      },
                    ),
                    const SizedBox(
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
                        height: 60.0,
                        child: const Center(
                          child: Text(
                            "Events Management",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold" ),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, EventManageScreen.idScreen, (route) => true);
                      },
                    ),
                    const SizedBox(
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
                        height: 60.0,
                        child: const Center(
                          child: Text(
                            "Travel Equipment Rent Shop Management",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold" ),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, EquipmentManageScreen.idScreen, (route) => true);
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
