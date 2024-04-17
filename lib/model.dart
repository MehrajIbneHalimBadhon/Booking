import 'package:cloud_firestore/cloud_firestore.dart';

class SportBooking {
  String? userId;
  String? userName;
  String? placeId;
  String? serviceName;
  String? serviceDuration;
  String? servicePrice;
  DateTime? bookingStart;
  DateTime? bookingEnd;
  String? email;
  String? phoneNumber;
  String? placeAddress;

  SportBooking({
    this.email,
    this.phoneNumber,
    this.placeAddress,
    this.bookingStart,
    this.bookingEnd,
    this.placeId,
    this.userId,
    this.userName,
    this.serviceName,
    this.serviceDuration,
    this.servicePrice,
  });

  static DateTime timeStampToDateTime(Timestamp timestamp) {
    return DateTime.parse(timestamp.toDate().toString());
  }

  static Timestamp dateTimeToTimeStamp(DateTime? dateTime) {
    return Timestamp.fromDate(dateTime ?? DateTime.now());
  }

  // Deserialize JSON to SportBooking object
  factory SportBooking.fromJson(Map<String, dynamic> json) {
    return SportBooking(
      userId: json['userId'],
      userName: json['userName'],
      placeId: json['placeId'],
      serviceName: json['serviceName'],
      serviceDuration: json['serviceDuration'],
      servicePrice: json['servicePrice'],
      bookingStart: json['bookingStart'] != null
          ? DateTime.parse(json['bookingStart'])
          : null,
      bookingEnd: json['bookingEnd'] != null
          ? DateTime.parse(json['bookingEnd'])
          : null,
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      placeAddress: json['placeAddress'],
    );
  }

  // Serialize SportBooking object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'placeId': placeId,
      'serviceName': serviceName,
      'serviceDuration': serviceDuration,
      'servicePrice': servicePrice,
      'bookingStart': bookingStart?.toIso8601String(),
      'bookingEnd': bookingEnd?.toIso8601String(),
      'email': email,
      'phoneNumber': phoneNumber,
      'placeAddress': placeAddress,
    };
  }
}
