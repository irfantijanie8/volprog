import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'certPage.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  String? name = '';
  String? email = '';
  String? image = '';
  int? eventNum = 0;
  File? imageXFile;

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['full name'];
          email = snapshot.data()!['email'];
          image = snapshot.data()!['userImage'];
          eventNum = snapshot.data()!['event num'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.2, 0.9])),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[300],
          title: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Profile Screen",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
                onTap: () {
                  //_showImageDialog
                },
                child: CircleAvatar(
                    backgroundColor: Colors.white,
                    minRadius: 60.0,
                    child: CircleAvatar(
                      radius: 55.0,
                      backgroundImage: imageXFile == null
                          ? NetworkImage(image!)
                          : Image.file(imageXFile!).image,
                    ))),
            const SizedBox(
              height: 10.0,
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Name : ' + name!,
                    style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ]),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              'Email : ' + email!,
              style: const TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ElevatedButton(
              child: Text('My certification'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => certPage(
                            text: {"name": name, "eventNum": eventNum})));
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
              ),
            ),
            // ElevatedButton(
            //     onPressed: _createPDF, child: Text('My Certification')),
          ],
        )));
  }

  // Future<void> _createPDF() async {
  //   PdfDocument document = PdfDocument();
  //   document.pageSettings.orientation = PdfPageOrientation.landscape;
  //   final page = document.pages.add();

  //   page.graphics.drawImage(PdfBitmap(await _readImageData('volcert.png')),
  //       Rect.fromLTWH(0, 0, 0, 0));
  //   page.graphics.drawImage(PdfBitmap(await _readImageData('pdf.png')),
  //       Rect.fromLTWH(80, 180, 0, 0));

  //   PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
  //   String fullName = name!;
  //   double size = fullName.length.toDouble();
  //   page.graphics.drawString(
  //       fullName, PdfStandardFont(PdfFontFamily.helvetica, 30),
  //       brush: PdfBrushes.black,
  //       bounds: Rect.fromLTWH((450 - (8.5 * size)), 340, 0, 0)); //200 - 700

  //   List<int> bytes = await document.save();
  //   document.dispose();

  //   saveAndLaunchFile(bytes, 'Cert.pdf');
  // }

  // Future<Uint8List> _readImageData(String Name) async {
  //   final data = await rootBundle.load('assets/images/$Name');
  //   return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  // }
}
