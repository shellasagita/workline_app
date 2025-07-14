class AttendanceHistory {
  final String? date;
  final String? checkIn;
  final String? checkOut;
  final String? location;

  AttendanceHistory({
    this.date,
    this.checkIn,
    this.checkOut,
    this.location,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      date: json['date'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      location: json['location'],
    );
  }
}
