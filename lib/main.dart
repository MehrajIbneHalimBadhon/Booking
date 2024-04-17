import 'package:booking_calendar/booking_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:turf_database_practice/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Initialize locale data
  await initializeDateFormatting();

  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DatabasePractice(),
    );
  }
}

class DatabasePractice extends StatefulWidget {
  const DatabasePractice({Key? key})
      : super(key: key); // Fixing the constructor

  @override
  State<DatabasePractice> createState() => _DatabasePracticeState();
}

class _DatabasePracticeState extends State<DatabasePractice> {
  final now = DateTime.now();
  late BookingService mockBookingService;

  @override
  void initState() {
    super.initState();
    // DateTime.now().startOfDay
    // DateTime.now().endOfDay
    mockBookingService = BookingService(
        serviceName: 'Mock Service',
        serviceDuration: 30,
        bookingEnd: DateTime(now.year, now.month, now.day, 18, 0),
        bookingStart: DateTime(now.year, now.month, now.day, 8, 0));
  }

  List<DateTimeRange> converted = [];
  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    ///take care this is only mock, so if you add today as disabledDays it will still be visible on the first load
    ///disabledDays will properly work with real data
    DateTime first = now;
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime second = now.add(const Duration(minutes: 55));
    DateTime third = now.subtract(const Duration(minutes: 240));
    DateTime fourth = now.subtract(const Duration(minutes: 500));
    converted.add(
        DateTimeRange(start: first, end: now.add(const Duration(minutes: 30))));
    converted.add(DateTimeRange(
        start: second, end: second.add(const Duration(minutes: 23))));
    converted.add(DateTimeRange(
        start: third, end: third.add(const Duration(minutes: 15))));
    converted.add(DateTimeRange(
        start: fourth, end: fourth.add(const Duration(minutes: 50))));

    //book whole day example
    converted.add(DateTimeRange(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 0)));
    return converted;
  }

  List<DateTimeRange> generatePauseSlots() {
    return [
      DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 12, 0),
          end: DateTime(now.year, now.month, now.day, 13, 0))
    ];
  }

  static CollectionReference bookings =
      FirebaseFirestore.instance.collection('bookings');

  static CollectionReference<Map<String, dynamic>> getBookingStream(
      {required String placeId}) {
    return bookings.doc(placeId).collection('bookings');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> Function({required DateTime end, required DateTime start}) getBookingStreamFirebase = ({
    required DateTime end,
    required DateTime start,
  }) {
    return getBookingStream(placeId: 'placeId')
        .where('bookingStart', isGreaterThanOrEqualTo: start)
        .where('bookingStart', isLessThanOrEqualTo: end)
        .snapshots();
  };


  List<DateTimeRange> convertStreamResultFirebase(
      {required QuerySnapshot<Map<String, dynamic>> streamResult}) {
    List<DateTimeRange> converted = [];
    for (var doc in streamResult.docs) {
      var data = doc.data();
      var bookingStart = data['bookingStart']?.toDate();
      var bookingEnd = data['bookingEnd']?.toDate();
      if (bookingStart != null && bookingEnd != null) {
        converted.add(DateTimeRange(start: bookingStart, end: bookingEnd));
      }
    }
    return converted;
  }

  Future<void> uploadBookingFirebase(
      {required BookingService newBooking}) async {
    try {
      await bookings
          .doc('your id, or autogenerate')
          .collection('bookings')
          .add(newBooking
              .toJson()) // Assuming newBooking is a BookingService object
          .then((value) => print("Booking Added"))
          .catchError((error) => print("Failed to add booking: $error"));
    } catch (error) {
      print("Failed to add booking: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings'),),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: 600,
            child: BookingCalendar(
              bookingService: mockBookingService,
              convertStreamResultToDateTimeRanges: convertStreamResultMock,
              getBookingStream: getBookingStreamFirebase,
              uploadBooking: uploadBookingFirebase,
              pauseSlots: generatePauseSlots(),
              pauseSlotText: 'LUNCH',
              hideBreakTime: false,
              loadingWidget: const Text('Fetching data...'),
              uploadingWidget: const CircularProgressIndicator(),
              startingDayOfWeek: StartingDayOfWeek.sunday,
              wholeDayIsBookedWidget:
                  const Text('Sorry, for this day everything is booked'),
              //disabledDates: [DateTime(2023, 1, 20)],
              //disabledDays: [6, 7],
            ),
          ),
        ),
      ),
    );
  }
}
