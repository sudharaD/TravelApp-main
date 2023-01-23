import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:travel_app/AllScreens/equipment/equipmentManageScreen.dart';
import 'package:travel_app/AllScreens/hotel/hotelManageScreen.dart';
import 'package:travel_app/AllScreens/vehicle/vehicleManageScreen.dart';

import '../Drawer/Drawer.dart';
import 'equipment/equipmentScreen.dart';
import 'equipment/equipmentUserListScreen.dart';
import 'event/eventManageScreen.dart';
import 'event/eventUserListScreen.dart';
import 'hotel/hotelUserListScreen.dart';
import 'vehicle/vehicleUserListScreen.dart';

class Accomadation extends StatefulWidget {
  static const String idScreen = "Accomadation";

  @override
  _Accomadation createState() => _Accomadation();
}

class _Accomadation extends State<Accomadation> {
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
        title: Text("Accomadation"),
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
                height: 45.0,
              ),
              const Image(
                image: AssetImage("images/logo.png"),
                width: 250.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
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
                            "Hotels List",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, HotelUserListScreen.idScreen, (route) => true);
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
                            "Vehicles List",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, VehicleUserListScreen.idScreen, (route) => true);
                      },
                    ),
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
                            "Travel Equipment Rent Shops",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold" ),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, EquipmentUserListScreen.idScreen, (route) => true);
                      },
                    ),
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
                            "Events List",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold" ),
                          ),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, EventUserListScreen.idScreen, (route) => true);
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
