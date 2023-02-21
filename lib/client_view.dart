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
    return Scaffold(
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
          builder: (context, ticketSnapshot) {
            if (!ticketSnapshot.hasData ||
                ticketSnapshot.hasError ||
                ticketSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (ticketSnapshot.hasData) {
              // last ticket number
              var lastTicket = ticketSnapshot.data!.docs.first.data() as Map;
              var lastTicketNumber = lastTicket['ticket_number'];
              print('last ticket number: $lastTicketNumber');

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('counters')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> counterSnapshot) {
                  if (counterSnapshot.hasError) {
                    return Text('Error: ${counterSnapshot.error}');
                  } else if (!counterSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else if (counterSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (counterSnapshot.hasData) {
                    var counterDocs = counterSnapshot.data!.docs;
                    int highestNumber = -1;
                    for (var doc in counterDocs) {
                      int currentNumber = doc['current_ticket'];
                      if (currentNumber > highestNumber) {
                        highestNumber = currentNumber;
                      }
                    }
                    print('highest number: $highestNumber');
                    // counters -> counter1 -> currentNumber, lastNumber, status
                    // get all documents and assign to a variable each
                    Map<String, Map<String, dynamic>> _counters = {};
                    // declare a map to store the counter data

                    counterSnapshot.data!.docs.forEach((doc) {
                      _counters[doc.id] = doc.data() as Map<String, dynamic>;
                    });
                    
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            children: [
                              Card(
                                child: Column(
                                  children: [
                                    Text(
                                        "Now Serving: $highestNumber"),
                                    Text("Last Number: $lastTicketNumber"),
                                    ElevatedButton(
                                      onPressed: () => generateTicketNumber()
                                          .then((value) =>
                                              _showTicketNumberPopup(
                                                  context, value)),
                                      child: Text("Take a Number"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Card(
                            child: Row(
                              children: [
                                CounterCard(
                                  status: _counters['counter1']!['status'],
                                  number: '1',
                                  lastNumber:
                                      _counters['counter1']!['last_ticket'],
                                  isOnline: _counters['counter1']!['is_online'],
                                ),
                                CounterCard(
                                  status: _counters['counter2']!['status'],
                                  number: '2',
                                  lastNumber:
                                      _counters['counter2']!['last_ticket'],
                                  isOnline: _counters['counter2']!['is_online'],
                                ),
                                CounterCard(
                                  status: _counters['counter3']!['status'],
                                  number: '3',
                                  lastNumber:
                                      _counters['counter3']!['last_ticket'],
                                  isOnline: _counters['counter3']!['is_online'],
                                ),
                                CounterCard(
                                  status: _counters['counter4']!['status'],
                                  number: '4',
                                  lastNumber:
                                      _counters['counter4']!['last_ticket'],
                                  isOnline: _counters['counter4']!['is_online'],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class CounterCard extends StatelessWidget {
  final String number;
  final bool status;
  final bool isOnline;
  final int lastNumber;

  const CounterCard({
    Key? key,
    required this.status,
    required this.isOnline,
    required this.number,
    required this.lastNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isOnline ? null : Colors.grey[200],
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: SizedBox(
                  height: 30,
                )), // Empty widget to create space at the top
                Text("Counter $number"),
                Text('Last Number: $lastNumber'),
                Expanded(
                    child:
                        SizedBox()), // Empty widget to create space at the bottom
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.circle,
              color:
                  isOnline ? (status ? Colors.green : Colors.red) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
