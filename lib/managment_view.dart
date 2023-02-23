import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagementView extends StatefulWidget {
  @override
  _ManagementViewState createState() => _ManagementViewState();
}

class _ManagementViewState extends State<ManagementView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('counters').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                final counterDocs = snapshot.data!.docs;

                // Map the document data to the CounterData model
                final counters = counterDocs
                    .map((doc) => CounterData(
                          counterNumber: doc.id,
                          status: doc.get('status'),
                          currentNumber: doc.get('current_ticket'),
                          is_online: doc.get('is_online'),
                        ))
                    .toList();
                final counterCards = counters
                    .map((counterData) => CounterCard(counterData: counterData))
                    .toList();
                // Build the UI using the CounterCard widget and
                //the CounterData model
                return Row(
                  // space between the counters
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: counterCards,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<bool> _callNext(String counterNumber) async {
  // TODO: god forgive me. I will refactor it later. I am tired.(split functions
  // and make it more readable)

  // get the oldest ticket that is not assigned to a counter
  final ticketQuery = FirebaseFirestore.instance
      .collection('tickets')
      .where('counter_number', isNull: true)
      .orderBy('ticket_number', descending: false)
      .limit(1);
  final counterDoc =
      FirebaseFirestore.instance.collection('counters').doc(counterNumber);

  // get the last ticket of the counter

  final ticketSnapshot = await ticketQuery.get();
  final ticketDocs = ticketSnapshot.docs;
  final ticket = ticketDocs.isNotEmpty ? ticketDocs.first : null;
  final currentCounter = await counterDoc.get();
  if (ticket != null) {
    // Update ticket with counter number

    await ticket.reference.update({'counter_number': counterNumber});

    // update the counter info
    int lastTicketNumber = currentCounter.data()!['current_ticket'];
    print('last ticket number: $lastTicketNumber');
    // Update counter with current ticket number
    final counterDoc =
        FirebaseFirestore.instance.collection('counters').doc(counterNumber);
    int currentTicketNumber = ticket.data()['ticket_number'];
    final counterSnapshot = await counterDoc.get();
    if (counterSnapshot.exists) {
      await counterDoc.update({
        'status': false,
        'current_ticket': currentTicketNumber,
        'last_ticket': lastTicketNumber
      });
    }
    return true;
  } else {
    // In case there are no tickets, set the counter status to true and currect
    // ticket to 0

    final counterSnapshot = await counterDoc.get();
    if (counterSnapshot.exists) {
      await counterDoc.update({'status': true, 'current_ticket': 0});
      return false;
    } else {
      // we should handle this case, probably a try catch.
      return false;
    }
  }
}

void _toggleCounterStatus(String counterNumber, bool currentStatus) async {
  // since we are using a stream builder we dont  need to update the UI using a
  // return value, the UI will be updated automatically once its set here.
  final counterDoc =
      FirebaseFirestore.instance.collection('counters').doc(counterNumber);
  final newStatus = currentStatus == true ? false : true;
  await counterDoc.update({'is_online': newStatus});
}

void _completeCurrent(String counterNumber) async {
  final counterRef =
      FirebaseFirestore.instance.collection('counters').doc(counterNumber);
  final counterDoc = await counterRef.get();
  final lastTicket = counterDoc.data()!['current_ticket'];
  await counterRef.update({
    'status': true,
    'last_ticket': lastTicket,
    'current_ticket': 0,
  });
}

class CounterCard extends StatelessWidget {
  final CounterData counterData;

  CounterCard({required this.counterData});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 300,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${counterData.counterNumber}',
              style: TextStyle(
                fontSize: 24, // Increase font size for counter name
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              child: Text(
                'Call Next',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () =>
                  _callNext(counterData.counterNumber).then((value) => {
                        if (value == true)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Next ticket called'),
                              ),
                            )
                          }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No tickets!, get some rest :)'),
                              ),
                            )
                          }
                      }),
            ),
            ElevatedButton(
              child: Text(
                'Complete\nCurrent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () => _completeCurrent(counterData.counterNumber),
            ),
            ElevatedButton(
              child: Text(
                counterData.is_online == true ? 'Go Offline' : 'Go Online',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onPressed: () => _toggleCounterStatus(
                counterData.counterNumber,
                counterData.is_online,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterData {
  final String counterNumber;
  final bool status;
  final bool is_online;
  final int currentNumber;

  CounterData({
    required this.counterNumber,
    required this.status,
    required this.is_online,
    required this.currentNumber,
  });
}
