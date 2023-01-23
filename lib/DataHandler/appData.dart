import 'package:flutter/cupertino.dart';
import 'package:travel_app/Models/address.dart';

class AppData extends ChangeNotifier {
  late Address pickUpLocation;

  void updatePickUpLocationAddress(Address pickUpAddress)
   {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }
}
