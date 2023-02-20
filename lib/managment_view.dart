import 'package:flutter/material.dart';
import 'dart:convert';
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          CounterCard(counterNumber: '1', status: 'online'),
          CounterCard(counterNumber: '2', status: 'offline'),
          CounterCard(counterNumber: '3', status: 'online'),
          CounterCard(counterNumber: '4', status: 'offline'),
        ],
      ),
    );
  }
}

class CounterManagmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

Future<void> _callNext(String  counterNumber) async {
  final ticketQuery = FirebaseFirestore.instance
      .collection('tickets')
      .where('counter_number', isEqualTo: '')
      .orderBy('timestamp')
      .limit(1);

  final ticketSnapshot = await ticketQuery.get();

  if (ticketSnapshot.docs.isNotEmpty) {
    final ticketDoc = ticketSnapshot.docs.first;
    await ticketDoc.reference.update({'counter_number': counterNumber});
  }
}


void _toggleCounterStatus(String counterNumber, String currentStatus) async {
  final counterDoc =
      FirebaseFirestore.instance.collection('counters').doc(counterNumber);
  final newStatus = currentStatus == 'online' ? 'offline' : 'online';
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
  });
}

class CounterCard extends StatelessWidget {
  final CounterData counterData;

  CounterCard({required this.counterData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  child: Text('Counter ${counterData.counterNumber}'),
                  padding: EdgeInsets.all(8.0),
                ),
              ),
              Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: counterData.status == 'online'
                      ? Colors.green
                      : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Current Number: ${counterData.currentNumber}',
            ),
          ),
          ButtonBar(
            children: [
              ElevatedButton(
                child: Text('Call Next'),
                onPressed: () => _callNext(counterData.counterNumber),
              ),
              ElevatedButton(
                child: Text('Complete Current'),
                onPressed: () => _completeCurrent(counterData.counterNumber),
              ),
              ElevatedButton(
                child: Text(counterData.status == 'online'
                    ? 'Go Offline'
                    : 'Go Online'),
                onPressed: () =>
                    _toggleCounterStatus(counterData.counterNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CounterData {
  final String counterNumber;
  final String status;
  final int currentNumber;

  CounterData({
    required this.counterNumber,
    required this.status,
    required this.currentNumber,
  });
}
