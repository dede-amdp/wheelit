import 'package:wheelit/activity/TicketScreen.dart';

class Ticket {
  TicketType type;
  String email,
      startDate,
      endDate,
      buyDate,
      buyTime; //startDate e endDate possono essere in un formato tale da contenere anche un orario così da poter fare anche "Abbonamenti per mezza giornata"
  bool used;
  Map mezzi;

  Ticket(
      {this.email,
      this.mezzi,
      this.buyDate,
      this.buyTime,
      this.startDate,
      this.endDate,
      this.type,
      this.used});

  String toCode() {
    Map code = {
      'email': this.email,
      'buyDate': this.buyDate,
      'buyTime': this.buyTime,
      'mezzi': this.mezzi.toString(),
      'used': this.used,
      'startDate': this.startDate,
      'endDate': this.endDate,
      'type': this.type == TicketType.NORMAL ? "NORMAL" : "PASS",
    };
    return code.toString();
  }

  static Ticket parseString(String ticketString) {
    Ticket finalTicket = Ticket();
    List<String> campi = ticketString
        .replaceAll('{', "")
        .replaceAll("}", "")
        .replaceAll(" ", "")
        .split(",");
    campi.forEach((element) {
      switch (element.split(":")[0]) {
        case 'user':
          finalTicket.email = element.split(":")[1];
          break;
        case 'buyTimeStamp':
          finalTicket.buyDate = TicketScreen.toLocalDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(element.split(':')[1].split("(")[1].split('=')[1]) *
                      1000))[0];
          finalTicket.buyTime = TicketScreen.toLocalDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(element.split(':')[1].split("(")[1].split('=')[1]) *
                      1000))[1];
          break;
        case 'public':
          Map mz = {};
          element
              .replaceFirst(":", "/")
              .split("/")[1]
              .split(',')
              .forEach((element) {
            mz.addAll({element.split(":")[0]: element.split(":")[1]});
          });
          finalTicket.mezzi = mz;
          break;
        case 'used':
          finalTicket.used = element.split(":")[1] == "true";
          break;
        case 'startDate':
          finalTicket.startDate = TicketScreen.toLocalDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(element.split(':')[1].split("(")[1].split('=')[1]) *
                      1000))[0];
          break;
        case 'endDate':
          finalTicket.endDate = TicketScreen.toLocalDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(element.split(':')[1].split("(")[1].split('=')[1]) *
                      1000))[0];
          break;
        case 'type':
          finalTicket.type = element.split(":")[1] == "NORMAL"
              ? TicketType.NORMAL
              : TicketType.PASS;
          break;
      }
    });
    return finalTicket;
  }
}

enum TicketType { NORMAL, PASS }
