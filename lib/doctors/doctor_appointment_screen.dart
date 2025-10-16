import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthcare/billing/payment_screen.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String imageUrl;

  const DoctorAppointmentScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.imageUrl,
  });

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> availableTimes = [
    "10:00 AM",
    "11:30 AM",
    "1:00 PM",
    "3:00 PM",
    "4:30 PM",
    "6:00 PM",
  ];

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _bookAppointment() {
    if (selectedDate == null || selectedTime == null) {
      GFToast.showToast(
        "Please select both date and time!",
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      return;
    }

    // GFToast.showToast(
    //   "Appointment booked with Dr. ${widget.doctorName} on ${DateFormat('dd MMM yyyy').format(selectedDate!)} at $selectedTime",
    //   context,
    //   toastPosition: GFToastPosition.BOTTOM,
    //   textStyle: const TextStyle(color: Colors.white),
    //   backgroundColor: Colors.green,
    // );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          doctorName: widget.doctorName,
          specialty: widget.specialty,
          appointmentDate: DateFormat('dd MMM yyyy').format(selectedDate!),
          appointmentTime: selectedTime!,
          consultationFee: 500.0, // You can make this dynamic later
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        title: Text("Book Appointment"),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GFCard(
              boxFit: BoxFit.cover,
              content: Row(
                children: [
                  GFAvatar(
                    backgroundImage: NetworkImage(widget.imageUrl),
                    shape: GFAvatarShape.circle,
                    size: GFSize.LARGE,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.specialty,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "4.8 (120 Reviews)",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker
            GFButton(
              onPressed: _pickDate,
              text: selectedDate == null
                  ? "Select Date"
                  : "Date: ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
              type: GFButtonType.outline,
              fullWidthButton: true,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),

            // Time Slots
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available Time Slots",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableTimes.map((time) {
                final isSelected = selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedTime = time;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),

            // Book Button
            GFButton(
              onPressed: _bookAppointment,
              text: "Book Appointment",
              fullWidthButton: true,
              color: Theme.of(context).primaryColor,
              shape: GFButtonShape.pills,
              size: GFSize.LARGE,
            ),
          ],
        ),
      ),
    );
  }
}
