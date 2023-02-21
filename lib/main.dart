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

  runApp(MaterialApp(
    title: 'Ticket Counter',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Ticketmain(),
  ));
}

// basic material app

class Ticketmain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Expanded(
          // half screen button taht will take you to the client view use stack

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TicketDashboard()),
              );
            },
            child: Text('Client View'),
          ),
        ),
        Expanded(
          // half screen button taht will take you to the management view
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManagementView()),
              );
            },
            child: Text('Management View'),
          ),
        ),
      ],
    ));
  }
}
