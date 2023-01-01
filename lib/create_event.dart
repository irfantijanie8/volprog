import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class createEvent extends StatefulWidget {
  const createEvent({super.key});

  @override
  State<createEvent> createState() => _createEventState();
}

class _createEventState extends State<createEvent> {
  final user = FirebaseAuth.instance.currentUser!;
  PlatformFile? pickedFile;

  DateTime todayDate = DateTime.now();
  DateTime eventDate = DateTime.now();

  TimeOfDay todayTime = TimeOfDay.now();
  TimeOfDay eventTime = TimeOfDay.now();

  String dateFormat = 'DD/MM/YY';
  String timeFormat = 'HH:MM';

  //controller
  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _eventLocationController = TextEditingController();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _eventLocationController.dispose();
  }

  //upload file
  Future uploadFile(DocumentReference docRef) async {
    final path = 'files/${docRef.id}.png';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
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
      'event name': _eventNameController.text.trim(),
      'event date': '${eventDate.day}/${eventDate.month}/${eventDate.year}',
      'event time': '${eventTime.hour}:${eventTime.minute}',
    });

    await FirebaseFirestore.instance
        .collection('createdEvent')
        .doc(user.uid + docRef.id)
        .set({
      'event id': docRef.id,
    });
    if (pickedFile!.name != "") uploadFile(docRef);
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
                SizedBox(height: 20),
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

                //time textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: TextField(
                        controller: _eventLocationController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Location',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //insert image
                Row(
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

                SizedBox(height: 20),
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