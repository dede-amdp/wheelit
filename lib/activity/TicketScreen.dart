import 'package:flutter/material.dart';
import 'package:wheelit/classes/Ticket.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wheelit/classes/DatabaseManager.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();

  static List toLocalDateTime(DateTime dt) {
    DateTime dateOriginal = DateTime.tryParse(dt.toString());
    List date = dateOriginal
        .add(Duration(hours: dateOriginal.timeZoneOffset.inHours))
        .toUtc()
        .toString()
        .split(" ");
    return date;
  }
}

class _TicketScreenState extends State<TicketScreen> {
  List<Ticket> ticketList = [];
  String userEmail = 'jhzvbjhasdbvhfsvg';

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
      body: ticketList == null
          ? Center(child: CircularProgressIndicator())
          : ticketList.isEmpty
              ? Center(
                  child: Text("Nessun biglietto acquistato",
                      style: TextStyle(fontSize: 24.0)))
              : ListView(
                  physics: BouncingScrollPhysics(),
                  children: ticketList.map((ticket) {
                    return Card(
                        child: ListTile(
                            leading: Icon(Icons.qr_code_rounded),
                            title: Text((ticket.type == TicketType.PASS
                                    ? 'Pass '
                                    : '') +
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
                                      width: MediaQuery.of(context).size.width -
                                          16.0,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
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
    Map tickets = await DatabaseManager.getTicketData(userEmail);
    List<Ticket> temp = [];
    tickets.forEach((key, value) {
      temp.add(Ticket.parseString(value.toString()));
    });
    setState(() {
      this.ticketList = temp;
    });
  }
}
