class Transport {
  TransportType type = TransportType.SCOOTER;
  TransportState state = TransportState.FREE;
  List position; //ha una latitudine e una longitudine
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
}

enum TransportType { BIKE, SCOOTER, BUS_STATION, TRAIN_STATION }
enum TransportState { FREE, RENTED }
