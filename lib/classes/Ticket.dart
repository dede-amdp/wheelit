class Ticket {
  TicketType type;
  String email,
      startDate,
      endDate,
      buyDate,
      buyTime; //startDate e endDate possono essere in un formato tale da contenere anche un orario così da poter fare anche "Abbonamenti per mezza giornata"
  bool used;
  List<String> mezzi;

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
    };
    return code.toString();
  }
}

enum TicketType { NORMAL, PASS }
