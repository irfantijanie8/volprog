import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'pickmap.dart';

class createEvent extends StatefulWidget {
  const createEvent({super.key});

  @override
  State<createEvent> createState() => _createEventState();
}

class _createEventState extends State<createEvent> {
  final user = FirebaseAuth.instance.currentUser!;
  String name = '';

  PlatformFile? pickedFile;

  DateTime todayDate = DateTime.now();
  DateTime eventDate = DateTime.now();

  TimeOfDay todayTime = TimeOfDay.now();
  TimeOfDay eventTime = TimeOfDay.now();

  String dateFormat = 'DD/MM/YY';
  String timeFormat = 'HH:MM';

  String latitude = '';
  String longitude = '';
  String place = '';

  String image = '';
  var info = new Map();

  //controller
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventNeeds1Controller = TextEditingController();
  final _eventNeeds2Controller = TextEditingController();
  final _eventNeeds3Controller = TextEditingController();
  final _eventNeeds4Controller = TextEditingController();

  final _eventIng1Controller = TextEditingController();
  final _eventIng2Controller = TextEditingController();
  final _eventIng3Controller = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventNeeds1Controller.dispose();
    _eventNeeds2Controller.dispose();
    _eventNeeds3Controller.dispose();
    _eventNeeds4Controller.dispose();
    _eventIng1Controller.dispose();
    _eventIng2Controller.dispose();
    _eventIng3Controller.dispose();
  }

  //upload file
  Future<String> uploadFile(DocumentReference docRef) async {
    final path = 'files/${docRef.id}.png';
    final file = File(pickedFile!.path!);
    String url = '';

    final ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    var dowurl = await (await uploadTask).ref.getDownloadURL();
    url = dowurl.toString();
    return url;
  }

  //select file
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  //send event to firebase
  Future eventCreation() async {
    String name = _eventNameController.text.trim();

    if (name == "") return;

    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('event').add({
      'organizer': user.uid,
      'event name': _eventNameController.text.trim(),
      'event date': '${eventDate.day}/${eventDate.month}/${eventDate.year}',
      'event time': '${eventTime.hour}:${eventTime.minute}',
      'latitude': latitude,
      'longitude': longitude,
      'description': _eventDescriptionController.text.trim(),
      'needs 1': _eventNeeds1Controller.text.trim(),
      'needs 2': _eventNeeds2Controller.text.trim(),
      'needs 3': _eventNeeds3Controller.text.trim(),
      'needs 4': _eventNeeds4Controller.text.trim(),
      'ingredient 1': _eventIng1Controller.text.trim(),
      'ingredient 2': _eventIng2Controller.text.trim(),
      'ingredient 3': _eventIng3Controller.text.trim(),
    });

    await FirebaseFirestore.instance
        .collection('createdEvent')
        .doc(user.uid + docRef.id)
        .set({
      'event id': docRef.id,
    });
    if (pickedFile!.name != "") {
      image = await uploadFile(docRef);
      print("url = $image");

      FirebaseFirestore.instance
          .collection('event')
          .doc(docRef.id)
          .set({'image': image}, SetOptions(merge: true)).then((value) {
        //Do your stuff.
      });
    }

    // Reference ref =
    //     FirebaseStorage.instance.ref().child("files/${docRef.id}.png");
    // try {
    //   String image = (await ref.getDownloadURL()).toString();
    //   print(image);
    // } catch (onError) {
    //   print("Error");
    // }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        title: Text('Create New Event'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  'Create Event',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Fill in the Event Details',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),

                //event name textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventNameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Event Name',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //event date event time text
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 68, right: 80),
                      child: Text('Event Date',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Text('Event Time',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))
                  ],
                ),

                //date icon
                Row(
                  children: [
                    ButtonTheme(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 17,
                          bottom: 10,
                          top: 0,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.calendar_month, size: 40.0),
                          onPressed: () async {
                            DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: todayDate,
                                firstDate: todayDate,
                                lastDate: DateTime(2100));
                            if (newDate == null) return;

                            setState(() => eventDate = newDate);
                          },
                        ),
                      ),
                    ),

                    //date box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 100,
                        height: 46,
                        child: Center(
                          child: Text(
                            ('${eventDate.day}/${eventDate.month}/${eventDate.year}'),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),

                    //time icon
                    ButtonTheme(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 17,
                          bottom: 10,
                          top: 0,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.timer_outlined, size: 40.0),
                          onPressed: () async {
                            TimeOfDay? newTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    const TimeOfDay(hour: 00, minute: 0));

                            if (newTime == null) return;

                            setState(() => eventTime = newTime);
                            setState(() => timeFormat =
                                '${eventTime.hour}:${eventTime.minute}');
                          },
                        ),
                      ),
                    ),

                    //time box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 100,
                        height: 46,
                        child: Center(
                          child: Text(
                            timeFormat,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                //text get location
                // Text('Location',
                //     style:
                //         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                //get location
                Row(
                  children: [
                    SelectionButton(onInfoChanged: (newInfo) {
                      info = newInfo;
                      setState(() {
                        place = info["places"];
                        latitude = info['latitude'];
                        longitude = info['longitude'];
                      });
                    }),

                    //location box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 230,
                        height: 46,
                        child: Center(
                          child: Text(
                            (place),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                //Description
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, right: 230),
                  child: Text('Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: _eventDescriptionController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Description',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //Needs
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, right: 276),
                  child: Text('Needs',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                //needs 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventNeeds1Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Needs 1',
                        ),
                      ),
                    ),
                  ),
                ),
                //needs 2
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventNeeds2Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Needs 2',
                        ),
                      ),
                    ),
                  ),
                ),
                //needs 3
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventNeeds3Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Needs 3',
                        ),
                      ),
                    ),
                  ),
                ),
                //needs 4
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventNeeds4Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Needs 4',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //ingredient
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, right: 276),
                  child: Text('Needs',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                //ingredient 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventIng1Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ingredient 1',
                        ),
                      ),
                    ),
                  ),
                ),
                //Ingredient 2
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventIng2Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ingredient 2',
                        ),
                      ),
                    ),
                  ),
                ),
                //Ingredient 3
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _eventIng3Controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ingredient 3',
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                //insert image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: GestureDetector(
                        onTap: selectFile,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                              child: Text('Upload Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ))),
                        ),
                      ),
                    ),
                    if (pickedFile != null)
                      Expanded(
                        child: Container(
                            color: Colors.blue[100],
                            child: Center(
                                child: Image.file(
                              File(pickedFile!.path!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ))),
                      )
                  ],
                ),
                if (pickedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 200),
                    child: Text(pickedFile!.name,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),

                SizedBox(height: 15),
                //create event button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: eventCreation,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text('Create Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//get data from widget
class SelectionButton extends StatefulWidget {
  final ValueChanged<Map> onInfoChanged;

  const SelectionButton({Key? key, required this.onInfoChanged})
      : super(key: key);

  @override
  State<SelectionButton> createState() => _SelectionButtonState();
}

class _SelectionButtonState extends State<SelectionButton> {
  late var result = new Map();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: ElevatedButton(
        onPressed: () async {
          result = await _navigateAndDisplaySelection(context);
          widget.onInfoChanged(result);
        },
        style: ElevatedButton.styleFrom(
            primary: Colors.deepPurple,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
        child: const Text('Get location'),
      ),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  Future<Map> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted)
      return {
        "latitude": "",
        "longitude": "",
        "places": "",
      };

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result['latitude'])));

    return result;
  }
}
