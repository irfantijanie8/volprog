import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'pdf.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  String? name = '';
  String? email = '';
  String? image = '';

  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          snapshot.data()!['full name'];
          snapshot.data()!['email'];
          snapshot.data()!['image'];
        });
      }
    });
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
      body: Center(
        child: Column(children: [
          ElevatedButton(onPressed: _createPDF, child: Text('Create PDF'))
        ]),
      ),
    );
  }

  Future<void> _createPDF() async {
    PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    final page = document.pages.add();

    page.graphics.drawImage(PdfBitmap(await _readImageData('volcert.png')),
        Rect.fromLTWH(0, 0, 0, 0));
    page.graphics.drawImage(PdfBitmap(await _readImageData('pdf.png')),
        Rect.fromLTWH(80, 180, 0, 0));

    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    String name = 'Muhammad';
    double size = name.length.toDouble();
    page.graphics.drawString(name, PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH((450 - (8.5 * size)), 340, 0, 0)); //200 - 700

    List<int> bytes = await document.save();
    document.dispose();

    saveAndLaunchFile(bytes, 'Cert.pdf');
  }

  Future<Uint8List> _readImageData(String Name) async {
    final data = await rootBundle.load('assets/images/$Name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
