import 'package:flutter/material.dart';
import 'client_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'managment_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(Ticketmain());
}

// basic material app

class Ticketmain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ManagementView(),
    );
  }
}
