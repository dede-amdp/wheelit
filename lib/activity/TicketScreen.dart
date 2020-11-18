import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<Ticket> ticketList = [];

  @override
  void initState() {
    super.initState();
    getUserTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("I tuoi biglietti:"),
          backgroundColor: Theme.of(context).accentColor),
      body: ticketList == null || ticketList.length == 0
          ? Center(child: CircularProgressIndicator())
          : ListView(
              physics: BouncingScrollPhysics(),
              children: ticketList.map((ticket) {
                return Card(
                    child: ListTile(
                        leading: Icon(Icons.qr_code_rounded),
                        title: Text(
                            (ticket.type == TicketType.PASS ? 'Pass ' : '') +
                                'Ticket bought on: ${ticket.buyDate}'),
                        subtitle: Text(ticket.type == TicketType.PASS
                            ? 'from: ${ticket.startDate} to ${ticket.endDate}'
                            : ''),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    content: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 16.0,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: Center(
                                    child: QrImage(
                                        data: ticket.toCode(), size: 500),
                                  ),
                                ));
                              });
                        }));
              }).toList(),
            ),
    );
  }

  Future<void> getUserTicket() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      for (int i = 0; i < 5; i++) {
        this.ticketList.add(Ticket(
            email: 'pippolippo@gmail.com',
            type: TicketType.NORMAL,
            mezzi: ['LINEA B${i + 1}'],
            buyDate: '${17 + i}/11/2020',
            buyTime: '${18 - i ~/ 2}:${i * 8 + i ~/ 2}:0$i'));
      }
      this.ticketList.add(Ticket(
            email: 'pippolippo@gmail.com',
            type: TicketType.PASS,
            mezzi: ['LINEA A1', 'LINEA A2', 'LINEA A3', 'LINEA A4', 'LINEA A5'],
            buyDate: '17/11/2020',
            buyTime: '15:26:57',
            startDate: '18/11/2020 00:01',
            endDate: '18/12/2020 23:59',
          ));
    });
  }
}
