import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketDashboard extends StatefulWidget {
  @override
  _TicketDashboardState createState() => _TicketDashboardState();
}

class _TicketDashboardState extends State<TicketDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _showTicketNumberPopup(
      BuildContext _context, String ticketNumber) async {
    showDialog(
      context: _context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ticket Number'),
          content: Text('Your ticket number is $ticketNumber.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> generateTicketNumber() async {
    final ticketDoc = FirebaseFirestore.instance.collection('tickets').doc();
    final ticketNumber =
        (await FirebaseFirestore.instance.collection('tickets').get())
                .docs
                .length +
            1;
    final timestamp = DateTime.now();
    await ticketDoc.set({
      'ticket_number': ticketNumber,
      'counter_number': null,
      'timestamp': timestamp,
    });
    return ticketNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('tickets').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.hasError ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                // last ticket number
                var tickerDocs = snapshot.data!.docs;
                var lastTicket = snapshot.data!.docs.last.data() as Map;
                var lastTicketNumber = lastTicket['ticket_number'];
                // get the last ticket number from the snapshot,
                // last ticket has the highest ticket number

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            Text("Now Serving: $lastTicketNumber"),
                            Text("Last Number: "),
                            ElevatedButton(
                              onPressed: () => generateTicketNumber().then(
                                  (value) =>
                                      _showTicketNumberPopup(context, value)),
                              child: Text("Take a Number"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
        Container(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('counters').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              var counterDocs = snapshot.data!.docs;
              // counters -> counter1 -> currentNumber, lastNumber, status,

              // get all documents and assign to a variable each
              Map<String, Map<String, dynamic>> _counters = {};
              // declare a map to store the counter data

              snapshot.data!.docs.forEach((doc) {
                _counters[doc.id] = doc.data() as Map<String,
                    dynamic>; // store each counter data in the map with the counter name as the key
              });

              return Card(
                child: Row(
                  children: [
                    CounterCard(
                      status: _counters['counter1']!['status'],
                      number: '1',
                      lastNumber: _counters['counter1']!['last_ticket'],
                      isOnline: _counters['counter1']!['is_online'],
                    ),
                    CounterCard(
                      status: _counters['counter2']!['status'],
                      number: '2',
                      lastNumber: _counters['counter2']!['last_ticket'],
                      isOnline: _counters['counter2']!['is_online'],
                    ),
                    CounterCard(
                      status: _counters['counter3']!['status'],
                      number: '3',
                      lastNumber: _counters['counter3']!['last_ticket'],
                      isOnline: _counters['counter3']!['is_online'],
                    ),
                    CounterCard(
                      status: _counters['counter4']!['status'],
                      number: '4',
                      lastNumber: _counters['counter4']!['last_ticket'],
                      isOnline: _counters['counter4']!['is_online'],
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ))
      ],
    );
  }
}

class CounterCard extends StatelessWidget {
  final String number;
  final bool status;
  final bool isOnline;
  final int lastNumber;

  const CounterCard(
      {Key? key,
      required this.status,
      required this.isOnline,
      required this.number,
      required this.lastNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          children: [
            Icon(
              Icons.circle,
              color: status ? Colors.green : Colors.red,
            ),
            Text("Counter $number"),
            Text('Last Number: $lastNumber'),
          ],
        ),
      ),
    );
  }
}
