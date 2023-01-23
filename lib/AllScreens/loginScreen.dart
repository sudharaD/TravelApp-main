import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/AllScreens/adminDashboard.dart';
import 'package:travel_app/AllScreens/registerationScreen.dart';
import 'package:travel_app/AllScreens/userDashboard.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatelessWidget 
{
  static const String idScreen = "login";
  final LocalStorage storage = new LocalStorage('localstorage_app');

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text("Login"),
    ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Padding(
          padding: EdgeInsets.all(8.0),
           child: Column(
            children: [
              SizedBox(height: 35.0,),
            const Image(
              image: AssetImage("images/logo.png"),
              width: 250.0,
              height: 250.0,
              alignment: Alignment.center,
            ),
              SizedBox(height: 10.0,),
              const Text(
                "Travel App",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),

              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                  SizedBox(height: 10.0,),
                  TextField(
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                  hintStyle: TextStyle (
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                ),
                style: TextStyle(fontSize: 14.0),
              ),

                  SizedBox(height: 10.0,),
                  TextField(
                  controller: passwordTextEditingController,
                  obscureText: true,  
                  decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                  hintStyle: TextStyle (
                    color: Colors.grey,
                    fontSize: 10.0,
                  ),
                ),
                style: TextStyle(fontSize: 14.0),
              ),

                SizedBox(height: 30.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0),
                          )
                      ),
                     child: Container(
                      height: 50.0 ,
                      child: const Center(
                      child: Text(
                          "Login",
                          style: TextStyle(fontSize: 18.0, fontFamily: "Brand Bold" ,color: Colors.white),
                      ),
                    ),
                  ),

                  onPressed: ()
                  {

                    if(!emailTextEditingController.text.contains("@"))
                    {
                      displayToastMessage("Email address is not valid", context);
                    }
                    else if(passwordTextEditingController.text.isEmpty)
                    {
                      displayToastMessage("Password is mandatory.", context);
                    }
                    else
                    {
                      loginAndAuthenticateUser(context);
                    }
                    
                  },
                ),

                  ],
                ),
                ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    )
                ),
                  onPressed: ()
                  {
                    Navigator.pushNamedAndRemoveUntil(context, RegisterationScreen.idScreen, (route) => true);
                  },
                  child: const Text(
                    "Do not have an Account? Register Here.",
                  ),
                ),
            ],
            ),
        ),
      ),
    );
  }
  void pout(context, meg)   {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      text: meg,
      confirmBtnText: 'Retry',
      confirmBtnColor: Colors.blue,
      onConfirmBtnTap: ()   {
        Navigator.pop(context);
      },
    );
  }
   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

   void loginAndAuthenticateUser(BuildContext context) async
   {
     showDialog(
         context: context,
         barrierDismissible: false,
         builder: (BuildContext context)
         {
           return LoginScreen();
         }
     );
     final FirebaseFirestore firestore = FirebaseFirestore.instance;

     final User? firebaseUser = (await _firebaseAuth
         .signInWithEmailAndPassword(
         email: emailTextEditingController.text,
         password: passwordTextEditingController.text
     ).catchError((errMsg){
       Navigator.pop(context);
       print("errMsg " + errMsg.toString() );
       if(errMsg.toString().contains( "user-not-found")){
         pout(context,"user not found");
        // displayToastMessage("user not found"  , context);
       }else{
         pout(context,"Check password");
        // displayToastMessage("Check password"  , context);
       }

     }
     )).user;

     if(firebaseUser != null)  //user created
         {

       storage.setItem('userid', firebaseUser.uid);

       print('firebaseUser.uid');
       print(firebaseUser.uid);
       print('firebaseUser.uid');

       try{
         Stream<DocumentSnapshot> stream = firestore.collection("users").doc(firebaseUser.uid).snapshots();

         stream.listen((snapshot) {
           storage.setItem('bio', snapshot["bio"].toString());
           storage.setItem('age', snapshot["age"].toString());
           storage.setItem('email', snapshot["email"].toString());
           storage.setItem('name', snapshot["name"].toString());
           storage.setItem('pic', snapshot["pic"].toString());
           print(snapshot["admin"]);
           if((snapshot["email"]).toString()=="admin@lk.lk"){
             storage.setItem('userType', "admin");
             Navigator.pushNamedAndRemoveUntil(context, AdminDashboard.idScreen, (route) => false);
          //   Navigator.pushNamedAndRemoveUntil(context, UserDashboard.idScreen, (route) => false);
             displayToastMessage("Welcome", context);
           }else{
             storage.setItem('userType', "user");
             Navigator.pushNamedAndRemoveUntil(context, UserDashboard.idScreen, (route) => false);

             //Navigator.pushNamedAndRemoveUntil(context, AdminDashboard.idScreen, (route) => false);
             displayToastMessage("Welcome", context);
           }
         });

       }catch (e){
         print(e);
       }

     }
     else
     {
       Navigator.pop(context);
       displayToastMessage("Error Occured, can not.", context);
     }

   }

}