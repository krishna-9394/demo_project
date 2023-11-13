  import 'dart:convert';
  import 'dart:io';
  import 'package:csv/csv.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'FirestoreDataStorage.dart';
import 'User.dart';
import 'firebase_options.dart';


  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Use the default options
    );
    runApp(MyApp());
  }
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: PickAndReadCSV(),
      );
    }
  }

  class PickAndReadCSV extends StatefulWidget {
    @override
    _PickAndReadCSVState createState() => _PickAndReadCSVState();
  }

  class _PickAndReadCSVState extends State<PickAndReadCSV> {
    List<User> users = [];
    void _addUserToFirebase() async {
      for(User user in users){
        _createSignUp(user);
      }
    }
    void _pickCSVFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        String? filePath = result.files.single.path;

        if (filePath == null) return; // User canceled the picker

        final input = File(filePath as String).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();
        List<User> temps = [];
        for(final row in fields){
          User user = User(row[0], row[1], row[2], row[3], row[4]);
          temps.add(user);
        }
        setState(() {
          users = temps;
        });

      }
      _addUserToFirebase();
    }

    Future<void> _createSignUp(User user) async {
      DataStorage dataStorage = DataStorage();
      await dataStorage.createUserWithProfile(user);
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('CSV File Picker and Reader'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _pickCSVFile,
                child: Text('Pick CSV File'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text("${users[index].name}\n${users[index].branch}\n${users[index].roll_no}\n${users[index].batch}\n${users[index].email}"),
                      onTap: () => _createSignUp(users[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }