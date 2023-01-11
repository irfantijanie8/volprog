import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'pdf.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class certPage extends StatefulWidget {
  final String text;
  certPage({Key? key, required this.text}) : super(key: key);

  @override
  State<certPage> createState() => _certPageState(text);
}

class _certPageState extends State<certPage> {
  late String name;
  _certPageState(this.name);
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
            "My Certification",
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
              height: 25,
            ),
            ElevatedButton(
                onPressed: _createPDF, child: Text('My Certification')),
          ],
        ),
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
    String fullName = name;
    double size = fullName.length.toDouble();
    page.graphics.drawString(
        fullName, PdfStandardFont(PdfFontFamily.helvetica, 30),
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
