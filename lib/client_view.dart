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

// hackery way to force the child streambuilder to rebuild.

  int _highestNumber = -1;
  Future _showTicketNumberPopup(
      BuildContext contextArg, String ticketNumber) async {
    showDialog(
      context: contextArg,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ticket Number'),
          content: Text('Your ticket number is $ticketNumber.'),
          actions: [
            TextButton(
              child: const Text('OK'),
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
              var ticketDocs = ticketSnapshot.data!.docs;
              int maxTicketNumber = 0;
              ticketDocs.forEach((doc) {
                var data = doc.data() as Map<String, dynamic>?;
                int? ticketNumber = data != null ? data['ticket_number'] : null;

                if (ticketNumber != null && ticketNumber > maxTicketNumber) {
                  maxTicketNumber = ticketNumber;
                }
              });

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('counters')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> counterSnapshot) {
                  if (counterSnapshot.hasError) {
                    return Text('Error: ${counterSnapshot.error}');
                  } else if (!counterSnapshot.hasData ||
                      counterSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (counterSnapshot.hasData) {
                    // Get the highest ticket number from the counters,
                    // because the last ticket number is not necessarily
                    // the highest number that is being served.
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      "Now Serving",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      highestNumber.toString(),
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Text(
                                      "Last Number: $maxTicketNumber",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey[800],
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () => generateTicketNumber()
                                          .then((value) =>
                                              _showTicketNumberPopup(
                                                  context, value)),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 64,
                                          vertical: 24,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        "Take a Number",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
      elevation: 4,
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
                  ),
                ), // Empty widget to create space at the top
                Text(
                  "Counter $number",
                  style: TextStyle(
                    fontSize: 20, // Increase font size
                    fontWeight: FontWeight.bold, // Add bold style
                  ),
                ),
                SizedBox(height: 10), // Add space between text elements
                Text(
                  'Last Number: $lastNumber',
                  style: TextStyle(
                    fontSize: 16, // Increase font size
                  ),
                ),
                Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Icon(
              Icons.circle,
              size: 30,
              color:
                  isOnline ? (status ? Colors.green : Colors.red) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
