class Transport {
  TransportType type = TransportType.SCOOTER;
  TransportState state = TransportState.FREE;
  String position; //ha una latitudine e una longitudine
  String code = 'A00000';
  double price = .1;
  int battery = 100;

  Transport(
      {this.code,
      this.state,
      this.position,
      this.battery,
      this.price,
      this.type});

  String transportTypetoString() {
    if (this.type == TransportType.BIKE)
      return "Electric bike";
    else if (this.type == TransportType.SCOOTER)
      return "Electric scooter";
    else if (this.type == TransportType.BUS_STATION)
      return "Bus station";
    else if (this.type == TransportType.TRAIN_STATION) return "Train station";
    return "";
  }

  static Transport parseString(String id, Map toParse) {
    Transport mezzo = Transport(code: id);
    print(toParse);
    String latlng =
        '[${toParse['position'].latitude}, ${toParse['position'].longitude}]';
    List campi = toParse.toString().split(",");
    campi.forEach((campo) {
      switch (campo.split(":")[0]) {
        case 'battery':
          mezzo.battery = int.parse(campo.split(":")[1]);
          break;
        case 'position':
          mezzo.position = '[$latlng]';
          break;
        case 'price':
          mezzo.price = double.parse(campo.split(":")[1]);
          break;
        case 'state':
          mezzo.state = campo.split(":")[1] == 'FREE'
              ? TransportState.FREE
              : TransportState.RENTED;
          break;
        case 'type':
          mezzo.type = campo.split(":")[1] == 'BIKE'
              ? TransportType.BIKE
              : campo.split(":")[1] == 'SCOOTER'
                  ? TransportType.SCOOTER
                  : campo.split(":")[1] == 'BUS'
                      ? TransportType.BUS_STATION
                      : TransportType.TRAIN_STATION;
          break;
      }
    });
    return mezzo;
  }
}

enum TransportType { BIKE, SCOOTER, BUS_STATION, TRAIN_STATION }
enum TransportState { FREE, RENTED }
