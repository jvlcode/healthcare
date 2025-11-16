import 'package:flutter/material.dart';
import 'package:healthcare/models/doctor_model.dart';
import 'package:healthcare/models/slot_model.dart';
import 'package:healthcare/services/slot_service.dart';
import 'package:intl/intl.dart';

class DoctorSlotManagementScreen extends StatefulWidget {
  const DoctorSlotManagementScreen({super.key});

  @override
  State<DoctorSlotManagementScreen> createState() =>
      _DoctorSlotManagementScreenState();
}

class _DoctorSlotManagementScreenState
    extends State<DoctorSlotManagementScreen> {
  // Each date contains a list of slots
  final Map<DateTime, List<Slot>> slotsByDate = {};
  bool isLoading = true;
  String? error;
  final service = SlotService();

  // Pick a date
  Future<DateTime?> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    return picked;
  }

  // Pick a time
  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return await showTimePicker(context: context, initialTime: initial);
  }

  Future<void> _addSlot() async {
    final date = await _pickDate();
    if (date == null) return;

    final start = await _pickTime(const TimeOfDay(hour: 9, minute: 0));
    if (start == null) return;

    final end = await _pickTime(
      TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null || _compareTimes(start, end) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    // Convert to 24-hour format for backend
    String format24(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final newStart = format24(start);
    final newEnd = format24(end);
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      final res = await service.createSlot(
        date: formattedDate,
        startTime: newStart,
        endTime: newEnd,
      );

      // Get the correct ID from response
      final slotId = res['data']['_id'] ?? res['data']['id'];
      if (slotId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to get slot ID from server")),
        );
        return;
      }

      // Now create the slot locally with correct ID
      final slot = Slot(
        id: slotId,
        startTime: newStart,
        endTime: newEnd,
        startTimeLabel: start.format(context),
        endTimeLabel: end.format(context),
        dateLabel: DateFormat('d MMM yyyy').format(date),
        date: date,
        available: true,
      );
      setState(() {
        slotsByDate.putIfAbsent(date, () => []).add(slot);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Slot created successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  int _compareTimes(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour - b.hour;
    return a.minute - b.minute;
  }

  void _editSlot(DateTime date, int index) async {
    final slot = slotsByDate[date]![index];
    if (!slot.available) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Slot already booked")));
      return;
    }

    final start = await _pickTime(const TimeOfDay(hour: 9, minute: 0));
    if (start == null) return;

    final end = await _pickTime(TimeOfDay(hour: start.hour + 1, minute: 0));
    if (end == null || _compareTimes(start, end) >= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid time range")));
      return;
    }
    String format24(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final newStart = format24(start);
    final newEnd = format24(end);
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Convert to 12-hour format for labels
    String format12(TimeOfDay t) => t.format(context);

    try {
      final response = await service.updateSlot(
        slotId: slot.id,
        date: formattedDate,
        startTime: newStart,
        endTime: newEnd,
      );

      if (response['success'] == true) {
        setState(() {
          slotsByDate[date]![index] = slot.copyWith(
            startTime: newStart,
            endTime: newEnd,
            startTimeLabel: format12(start),
            endTimeLabel: format12(end),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Slot updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update slot: ${response['message']}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _deleteSlot(DateTime date, int index) async {
    final slot = slotsByDate[date]![index];

    if (!slot.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete booked slot")),
      );
      return;
    }

    try {
      final response = await service.deleteSlot(slot.id);

      if (response == true) {
        setState(() {
          slotsByDate[date]!.removeAt(index);
          if (slotsByDate[date]!.isEmpty) slotsByDate.remove(date);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Slot deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete slot")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final service = SlotService();
      final res = await service.getSlotList("6915ffdd11f70d575e38edfb");

      // print("[Slot screen] $res");
      if (res['success'] == true) {
        final List<Map<String, dynamic>> raw = List<Map<String, dynamic>>.from(
          res['data'],
        );
        final List<Slot> slots = raw.map((e) => Slot.fromJson(e)).toList();
        print(res['data']);
        final Map<DateTime, List<Slot>> grouped = {};
        for (final slot in slots) {
          final date = DateTime(slot.date.year, slot.date.month, slot.date.day);
          grouped.putIfAbsent(date, () => []).add(slot);
        }

        setState(() {
          slotsByDate.clear();
          slotsByDate.addAll(grouped);
          isLoading = false;
        });
      } else {
        throw Exception(res['message']);
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = slotsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Slot Management",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF6B35),
        onPressed: _addSlot,
        label: const Text("Add Slot"),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sortedDates.isEmpty
            ? const Center(
                child: Text(
                  "No slots added yet",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final dateSlots = slotsByDate[date]!;
                  final formattedDate = DateFormat(
                    'EEE, MMM d, yyyy',
                  ).format(date);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF01312F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...dateSlots.map((slot) {
                            final isBooked = !slot.available;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isBooked
                                          ? Colors.red.shade100
                                          : Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      isBooked ? Icons.lock : Icons.schedule,
                                      color: isBooked
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${slot.startTimeLabel} - ${slot.endTimeLabel}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          isBooked ? "Booked" : "Available",
                                          style: TextStyle(
                                            color: isBooked
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                    onPressed: () => _editSlot(
                                      date,
                                      dateSlots.indexOf(slot),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => _deleteSlot(
                                      date,
                                      dateSlots.indexOf(slot),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
