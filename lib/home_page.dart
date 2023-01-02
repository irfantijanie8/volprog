import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volprog/create_event.dart';
import 'package:volprog/get_user_name.dart';
import 'profile_page.dart';

import 'pickmap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // document IDs
  List<String> docIDs = [];

  //get docid
  Future getDocId() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            print(document.reference);
            docIDs.add(document.reference.id);
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('signed in, as: ' + user.uid!),
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            color: Colors.deepPurple[200],
            child: Text('Sign out'),
          ),
          ElevatedButton(
            child: Text('Register Event'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => createEvent()));
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
            ),
          ),

          //testmap
          ElevatedButton(
            child: Text('Profile Page'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => profilePage()));
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.purple,
            ),
          ),

          Expanded(
              child: FutureBuilder(
            future: getDocId(),
            builder: (context, snapshot) {
              return ListView.builder(
                  itemCount: docIDs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: GetUserName(
                      documentId: docIDs[index],
                    ));
                  });
            },
          ))
        ],
      )),
    );
  }
}
