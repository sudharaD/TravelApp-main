import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'AllScreens/calenderScreen.dart';
import 'AllScreens/equipment/equipmentEditScreen.dart';
import 'AllScreens/equipment/equipmentListScreen.dart';
import 'AllScreens/equipment/equipmentUserListScreen.dart';
import 'AllScreens/equipment/equipmentViewScreen.dart';
import 'AllScreens/event/eventEditScreen.dart';
import 'AllScreens/event/eventListScreen.dart';
import 'AllScreens/event/eventManageScreen.dart';
import 'AllScreens/event/eventScreen.dart';
import 'AllScreens/event/eventUserListScreen.dart';
import 'AllScreens/event/eventUserViewScreen.dart';
import 'AllScreens/event/eventViewScreen.dart';
import 'AllScreens/hotel/hotelEditScreen.dart';
import 'AllScreens/hotel/hotelUserListScreen.dart';
import 'AllScreens/hotel/hotelViewScreen.dart';
import 'AllScreens/landing/landingEditScreen.dart';
import 'AllScreens/landing/landingListScreen.dart';
import 'AllScreens/landing/landingManageScreen.dart';
import 'AllScreens/landing/landingScreen.dart';
import 'AllScreens/landing/mainViewScreen.dart';
import 'AllScreens/vehicle/vehicleEditScreen.dart';
import 'AllScreens/vehicle/vehicleListScreen.dart';
import 'AllScreens/vehicle/vehicleUserListScreen.dart';
import 'AllScreens/vehicle/vehicleViewScreen.dart';
import 'DataHandler/appData.dart';
import 'AllScreens/loginScreen.dart';
import 'AllScreens/registerationScreen.dart';
import 'AllScreens/accomadation.dart';
import 'AllScreens/adminDashboard.dart';
import 'AllScreens/equipment/equipmentManageScreen.dart';
import 'AllScreens/equipment/equipmentScreen.dart';
import 'AllScreens/hotel/hotelListScreen.dart';
import 'AllScreens/hotel/hotelManageScreen.dart';
import 'AllScreens/hotel/hotelScreen.dart';
import 'AllScreens/profileScreen.dart';
import 'AllScreens/userDashboard.dart';
import 'AllScreens/vehicle/vehicleManageScreen.dart';
import 'AllScreens/vehicle/vehicleScreen.dart';
import 'AllScreens/welcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppData(),
    child: MaterialApp(
      title: 'Traveler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: WelcomeScreen.idScreen,
      routes:
      {
        MainScreen.idScreen: (context) => MainScreen(),
        LandingScreen.idScreen: (context) => LandingScreen(),
        LandingListScreen.idScreen: (context) => LandingListScreen(),
        MainViewScreen.idScreen: (context) => MainViewScreen(name:'' ,province:'',district:'',city:'',nearestTown:'' ,dis:'', pic:'' ,lat:'',lng:''),
        WelcomeScreen.idScreen: (context) => WelcomeScreen(),
        RegisterationScreen.idScreen: (context) => RegisterationScreen(),
        LoginScreen.idScreen: (context) => LoginScreen(),
        AdminDashboard.idScreen: (context) => AdminDashboard(),
        UserDashboard.idScreen: (context) => UserDashboard(),
        ProfileScreen.idScreen: (context) => ProfileScreen(),
        Accomadation.idScreen: (context) => Accomadation(),
        HotelScreen.idScreen: (context) => HotelScreen(),
        VehicleScreen.idScreen: (context) => VehicleScreen(),
        HotelManageScreen.idScreen: (context) => HotelManageScreen(),
        VehicleManageScreen.idScreen: (context) => VehicleManageScreen(),
        HotelListScreen.idScreen: (context) => HotelListScreen(),
        HotelUserListScreen.idScreen: (context) => HotelUserListScreen(),
        HotelViewScreen.idScreen: (context) => HotelViewScreen(name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:''),
        HotelEditScreen.idScreen: (context) => HotelEditScreen(id:'',name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:''),

        LandingEditScreen.idScreen: (context) => LandingEditScreen(id:'',name:'' ,province:'',district:'',city:'',nearestTown:'', dis:'',lat:'',lng:'',pic:'' ),

        VehicleListScreen.idScreen: (context) => VehicleListScreen(),
        VehicleUserListScreen.idScreen: (context) => VehicleUserListScreen(),
        VehicleViewScreen.idScreen: (context) => VehicleViewScreen(name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:'', seats: '', category: ''),
        VehicleEditScreen.idScreen: (context) => VehicleEditScreen(id:'',name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:'', seats: '', category: ''),
        EquipmentScreen.idScreen: (context) => EquipmentScreen(),
        EquipmentUserListScreen.idScreen: (context) => EquipmentUserListScreen(),
        EquipmentListScreen.idScreen: (context) => EquipmentListScreen(),
        EquipmentManageScreen.idScreen: (context) => EquipmentManageScreen(),
        EquipmentViewScreen.idScreen: (context) => EquipmentViewScreen(name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:''),
        EquipmentEditScreen.idScreen: (context) => EquipmentEditScreen(id:'',name:'',address:'',province:'',district:'',city:'',nearestTown:'',email:'',phone:'',dis:'',lat:'',lng:'',pic:'',pic1:''),
        EventScreen.idScreen: (context) => EventScreen(),
        EventUserListScreen.idScreen: (context) => EventUserListScreen(),
        EventListScreen.idScreen: (context) => EventListScreen(),
        EventUserViewScreen.idScreen: (context) => EventUserViewScreen(id:'',lat:'',lng:'',lat1:'',lng1:'',m_count:'',budget:'',date:'',duration:'',des:'',pic:'',pic1:'',userid:''),
        EventManageScreen.idScreen: (context) => EventManageScreen(),
        EventViewScreen.idScreen: (context) => EventViewScreen(id:'',lat:'',lng:'',lat1:'',lng1:'',m_count:'',budget:'',date:'',duration:'',des:'',pic:'',pic1:'',userid:''),
        EventEditScreen.idScreen: (context) => EventEditScreen(id:'',lat:'',lng:'',lat1:'',lng1:'',m_count:'',budget:'',date:'',duration:'',des:'',pic:'',pic1:''),
        CalenderScreen.idScreen: (context) => CalenderScreen(),
      },
      debugShowCheckedModeBanner: false,
    ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(6.887889, 79.918528),zoom: 15),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
