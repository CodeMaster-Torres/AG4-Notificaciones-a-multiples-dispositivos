import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    checkUserAuth();
    super.initState();
  }

  checkUserAuth() async {
    try {
      User? user = auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error A " + e.toString());
    }
  }

  // Método para loguear
  login() async {
    String email = mailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential result = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Registrar fcm key
        String? token = await firebaseMessaging.getToken();
        User? user = result.user;
        await db.collection("users").doc(user!.uid).set({
          "email": user.email,
          "fcmToken": token,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } catch (error) {
        showToast("Error " + error.toString(), gravity: ToastGravity.CENTER);
      }
    } else {
      showToast("Provide email and password", gravity: ToastGravity.CENTER);
    }
  }

  void showToast(String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: mailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                  labelText: "Password",
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
            ),
            MaterialButton(
              color: Colors.green,
              child: Text("Login"),
              onPressed: login,
            ),
          ],
        ),
      ),
    );
  }
}
