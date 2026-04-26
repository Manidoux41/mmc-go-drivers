class Trip {
  final String id;
  final String routeName;
  final DateTime startTime;
  final String departure;
  final String arrival;
  final String busNumber;
  final bool isCompleted;

  Trip({
    required this.id,
    required this.routeName,
    required this.startTime,
    required this.departure,
    required this.arrival,
    required this.busNumber,
    this.isCompleted = false,
  });
}
