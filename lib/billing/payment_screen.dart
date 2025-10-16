import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String appointmentDate;
  final String appointmentTime;
  final double consultationFee;

  const PaymentScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.consultationFee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPayment = "UPI";

  final List<String> paymentMethods = [
    "UPI",
    "Credit Card",
    "Debit Card",
    "Net Banking",
  ];

  void _confirmPayment() {
    GFToast.showToast(
      "Payment Successful! Appointment confirmed with Dr. ${widget.doctorName}",
      context,
      toastPosition: GFToastPosition.BOTTOM,
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white),
    );

    Navigator.pop(context); // Go back after confirmation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        title: const Text("Payment"),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment Summary
            GFCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appointment Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Doctor: ${widget.doctorName}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    "Specialty: ${widget.specialty}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    "Date: ${widget.appointmentDate}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    "Time: ${widget.appointmentTime}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Consultation Fee",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "₹${widget.consultationFee.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Method Section
            Text(
              "Select Payment Method",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            ...paymentMethods.map((method) {
              return GFListTile(
                titleText: method,
                avatar: Icon(
                  method == "UPI"
                      ? Icons.account_balance_wallet
                      : method == "Credit Card"
                      ? Icons.credit_card
                      : method == "Debit Card"
                      ? Icons.credit_card_outlined
                      : Icons.account_balance,
                  color: Theme.of(context).primaryColor,
                ),
                icon: Radio<String>(
                  value: method,
                  groupValue: selectedPayment,
                  onChanged: (val) {
                    setState(() {
                      selectedPayment = val!;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              );
            }).toList(),

            const Spacer(),

            // Confirm Button
            GFButton(
              onPressed: _confirmPayment,
              text: "Pay ₹${widget.consultationFee.toStringAsFixed(2)}",
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
