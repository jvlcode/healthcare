import 'package:flutter/material.dart';

/* ------------------------
   5) Slot Management Screen
   ------------------------ */
class Slot {
  Slot({
    required this.day,
    required this.start,
    required this.end,
    this.booked = false,
  });
  final String day;
  TimeOfDay start;
  TimeOfDay end;
  bool booked;
}

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  final List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  String selectedDay = 'Mon';
  List<Slot> slots = [];

  // Example: Some slots are 'booked' to demonstrate prevention
  @override
  void initState() {
    super.initState();
    // optional: prepopulate with one taken slot
    slots.add(
      Slot(
        day: 'Mon',
        start: TimeOfDay(hour: 10, minute: 0),
        end: TimeOfDay(hour: 11, minute: 0),
        booked: true,
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return await showTimePicker(context: context, initialTime: initial);
  }

  Future<void> _addSlot() async {
    final start = await _pickTime(const TimeOfDay(hour: 9, minute: 0));
    if (start == null) return;
    final end = await _pickTime(
      TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null) return;
    if (_timeCompare(start, end) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start')),
      );
      return;
    }
    setState(() {
      slots.add(Slot(day: selectedDay, start: start, end: end, booked: false));
    });
  }

  void _editSlot(int index) async {
    final slot = slots[index];
    if (slot.booked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot already booked and cannot be edited'),
        ),
      );
      return;
    }
    final newStart = await _pickTime(slot.start);
    if (newStart == null) return;
    final newEnd = await _pickTime(slot.end);
    if (newEnd == null) return;
    if (_timeCompare(newStart, newEnd) >= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start')),
      );
      return;
    }
    setState(() {
      slot.start = newStart;
      slot.end = newEnd;
    });
  }

  void _deleteSlot(int index) {
    final slot = slots[index];
    if (slot.booked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete a booked slot')),
      );
      return;
    }
    setState(() {
      slots.removeAt(index);
    });
  }

  int _timeCompare(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour - b.hour;
    return a.minute - b.minute;
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$min $period';
  }

  // For demo: toggle booked status (simulate a booking by a patient)
  void _toggleBooked(int index) {
    setState(() => slots[index].booked = !slots[index].booked);
  }

  @override
  Widget build(BuildContext context) {
    final daySlots = slots.where((s) => s.day == selectedDay).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Slots')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // day selector
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekdays.length,
                itemBuilder: (context, idx) {
                  final d = weekdays[idx];
                  final selected = d == selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = d),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF01312F)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF01312F)),
                      ),
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF01312F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Slot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // bulk remove (only unbooked) demonstration
                    setState(() {
                      slots.removeWhere(
                        (s) => s.day == selectedDay && !s.booked,
                      );
                    });
                  },
                  child: const Text('Clear Unbooked'),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Expanded(
              child: daySlots.isEmpty
                  ? const Center(child: Text('No slots for selected day'))
                  : ListView.builder(
                      itemCount: daySlots.length,
                      itemBuilder: (context, i) {
                        final slot = daySlots[i];
                        final idx = slots.indexOf(slot);
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              slot.booked ? Icons.lock : Icons.schedule,
                              color: slot.booked ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              '${_formatTime(slot.start)}  —  ${_formatTime(slot.end)}',
                            ),
                            subtitle: Text(
                              slot.booked
                                  ? 'Booked (cannot edit)'
                                  : 'Available',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editSlot(idx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteSlot(idx),
                                ),
                                IconButton(
                                  icon: Icon(
                                    slot.booked
                                        ? Icons.person_remove
                                        : Icons.person_add,
                                  ),
                                  onPressed: () => _toggleBooked(idx),
                                  tooltip: 'Simulate booking toggle',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // In real app: persist to backend
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Slots saved locally (demo)'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Save Slots', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
