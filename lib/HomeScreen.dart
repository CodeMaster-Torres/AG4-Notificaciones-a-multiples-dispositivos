import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ag4_push/LoginScreen.dart';
import 'package:ag4_push/MessageScreen.dart';
import 'package:ag4_push/main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<DocumentSnapshot>? users;

  get usuariologueado => null;

  @override
  void initState() {
    super.initState();
    _getUsers();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showMessage("Notificación: ", "${message.notification!.title} ${message.notification!.body}");
      }
    });
  }

  _showMessage(title, message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: Text("Dismiss"),
            )
          ],
        );
      },
    );
  }

  _getUsers() async {
    try {
      QuerySnapshot snapshot = await db.collection("users").get();
      setState(() {
        users = snapshot.docs;
        users?.removeWhere((element)=>element.data().toString().contains(usuariologueado!));
        print(users);
      });
    } catch (e) {
      print("Error getting users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: Colors.black,
            onPressed: () {
              FirebaseAuth.instance.signOut().then((val) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              });
            },
          )
        ],
      ),
      body: Container(
        child: users != null
            ? ListView.builder(
          itemCount: users!.length,
          itemBuilder: (ctx, index) {
            var userData = users![index].data() as Map<String, dynamic>?; // Cast to Map<String, dynamic> or use .get('field')
            return Container(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(userData?["email"]
                      .toString()
                      .substring(0, 1) ?? ""),
                ),
                title: Text(userData?["email"] ?? ""),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageScreen(
                        doc: users![index],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
            : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
