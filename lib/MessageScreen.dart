import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final DocumentSnapshot doc;

  MessageScreen({
    required this.doc,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late String userEmail;

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  void getUserEmail() {
    userEmail = widget.doc.get('email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userEmail),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Enviar mensaje a $userEmail',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            // Aquí va tu lógica para enviar mensajes
          ],
        ),
      ),
    );
  }
}
