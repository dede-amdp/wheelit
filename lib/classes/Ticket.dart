import 'package:wheelit/activity/TicketScreen.dart';
import 'package:meta/meta.dart';

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
      {@required this.email,
      @required this.mezzi,
      @required this.buyDate,
      @required this.buyTime,
      this.startDate,
      this.endDate,
      this.type,
      this.used});

  Map toMap() {
    Map code = {
      'email': this.email,
      'buyDate': this.buyDate,
      'buyTime': this.buyTime,
      'mezzi': this.mezzi,
      'used': this.used,
      'startDate': this.startDate,
      'endDate': this.endDate,
      'type': this.type
    };
    return code;
  }

  String toString() {
    List date = buyDate.split('-');
    List startDateList = startDate.split('-');
    List endDateList = endDate.split('-');

    String lines = this
        .mezzi
        .keys
        .toList()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');
    String toReturn = 'Ticket bought on: ';
    toReturn += '${date[2]}/${date[1]}/${date[0]}' +
        " at " +
        buyTime.substring(0, 5) +
        "\n";
    toReturn += "Valid for: " + lines + '\n';
    if (type == TicketType.PASS)
      toReturn += 'Valid through: ' +
          '${startDateList[2]}/${startDateList[1]}/${startDateList[0]}' +
          ' to ' +
          '${endDateList[2]}/${endDateList[1]}/${endDateList[0]}' +
          "\n";
    toReturn += 'Ticket bought by $email\non Wheelit :D';
    return toReturn;
  }

  String toCode() {
    Map m = toMap();
    m['type'] = toMap()['type'] =
        toMap()[type] == TicketType.NORMAL ? "NORMAL" : "PASS";
    return m.toString();
  }

  static Ticket parseString(Map ticketData, {bool id}) {
    //Genera un Ticket da una stringa
    if (id != null) {
      if (id) ticketData = ticketData.values.toList()[0];
    }
    String ticketString = ticketData.toString().toString();
    Ticket finalTicket = Ticket(email: "", mezzi: {}, buyDate: "", buyTime: "");
    List<String> campi = ticketString
        .replaceAll('{', "")
        .replaceAll("}", "")
        .replaceAll(" ", "")
        .split(","); //sostituiamo i caratteri inutili e dividiamo per campi
    campi.forEach((element) {
      switch (element.split(":")[0]) {
        //la prima parte del campo è il suo nome: lo usiamo per capire a quale attributo assegnare il valore
        case 'user':
          finalTicket.email = element.split(":")[1];
          break;
        case 'buyTimeStamp': //Prende il numero di secondi (Epoch) e li converte in DateTime che poi è convertito in Data e ora dal metodo toLocalDateTime
          finalTicket.buyDate = TicketScreen.toLocalDateTime(
              ticketData['buyTimeStamp'].toDate(),
              local: true)[0];
          finalTicket.buyTime = TicketScreen.toLocalDateTime(
              ticketData['buyTimeStamp'].toDate(),
              local: true)[1];
          break;
        case 'public': //converte la stringa di mezzi in una mappa di mezzi
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
        case 'startDate': //Come per buyTimeStamp
          finalTicket.startDate = TicketScreen.toLocalDateTime(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(element.split(':')[1].split("(")[1].split('=')[1]) *
                      1000))[0];
          break;
        case 'endDate': //Come per buyTimeStamp
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
