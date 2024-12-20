import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MakeReservationPage extends StatefulWidget {
  final dynamic room;

  const MakeReservationPage({Key? key, required this.room}) : super(key: key);

  @override
  _MakeReservationPageState createState() => _MakeReservationPageState();
}

class _MakeReservationPageState extends State<MakeReservationPage> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isLoading = false;

  Future<void> checkAvailability() async {
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Odada mevcut rezervasyonları Firestore'dan getir
      QuerySnapshot reservations = await FirebaseFirestore.instance
          .collection('Reservations')
          .where('roomId', isEqualTo: widget.room.id)
          .get();

      bool isAvailable = true;
      List<DateTime> unavailableDates = [];

      for (var reservation in reservations.docs) {
        DateTime start = (reservation['startDate'] as Timestamp).toDate();
        DateTime end = (reservation['endDate'] as Timestamp).toDate();

        // Tarihler çakışıyor mu kontrol et
        if (!(selectedEndDate!.isBefore(start) || selectedStartDate!.isAfter(end))) {
          isAvailable = false;
          unavailableDates.add(start);
          unavailableDates.add(end);
        }
      }

      if (isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This room is available!')),
        );

        // Rezervasyonu tamamlamak için bir sonraki adıma yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmReservationPage(
              room: widget.room,
              startDate: selectedStartDate!,
              endDate: selectedEndDate!,
            ),
          ),
        );
      } else {
        // Yakın tarihleri öner
        unavailableDates.sort(); // Tarihleri sırala
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room is not available for selected dates.')),
        );
        showSuggestions(unavailableDates);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking availability: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSuggestions(List<DateTime> unavailableDates) {
    DateTime? closestBefore;
    DateTime? closestAfter;

    for (var date in unavailableDates) {
      if (date.isBefore(selectedStartDate!)) {
        closestBefore = date;
      } else if (date.isAfter(selectedEndDate!)) {
        closestAfter = date;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternative Dates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (closestBefore != null) Text('Closest available before: ${closestBefore.toLocal()}'),
            if (closestAfter != null) Text('Closest available after: ${closestAfter.toLocal()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Reservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Reserve Room: ${widget.room['type']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Başlangıç tarihi seçimi
            TextButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    selectedStartDate = picked;
                  });
                }
              },
              child: Text(
                selectedStartDate == null
                    ? 'Select Start Date'
                    : 'Start Date: ${selectedStartDate!.toLocal()}',
              ),
            ),
            const SizedBox(height: 20),
            // Bitiş tarihi seçimi
            TextButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedStartDate ?? DateTime.now(),
                  firstDate: selectedStartDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    selectedEndDate = picked;
                  });
                }
              },
              child: Text(
                selectedEndDate == null
                    ? 'Select End Date'
                    : 'End Date: ${selectedEndDate!.toLocal()}',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAvailability,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Check Availability'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmReservationPage extends StatelessWidget {
  final dynamic room;
  final DateTime startDate;
  final DateTime endDate;

  const ConfirmReservationPage({
    Key? key,
    required this.room,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Reservation'),
      ),
      body: Center(
        child: Text(
          'Reservation confirmed for ${room['type']} from ${startDate.toLocal()} to ${endDate.toLocal()}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
