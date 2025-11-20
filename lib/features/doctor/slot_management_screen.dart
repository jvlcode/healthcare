import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/widgets/confirmation_dialog.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
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
  final Map<DateTime, List<Slot>> slotsByDate = {};
  bool _loading = true;
  String? _error;
  final service = SlotService();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (!mounted) return;
    setState(() => _error = null);

    try {
      final user = await SessionManager.getCurrentUser();
      if (user?.doctor?.id == null) {
        setState(() {
          _error = "Doctor not found";
          _loading = false;
        });
        return;
      }

      await NetworkHelper().safeCall(
        context,
        () => service.getSlotList(user!.doctor!.id),
        onSuccess: (res) {
          final raw = (res['data'] as List<dynamic>?) ?? [];
          final slots = raw
              .map((e) => Slot.fromJson(e as Map<String, dynamic>))
              .toList();

          final grouped = <DateTime, List<Slot>>{};
          for (var slot in slots) {
            final date = DateTime(
              slot.date.year,
              slot.date.month,
              slot.date.day,
            );
            grouped.putIfAbsent(date, () => []).add(slot);
          }

          setState(() {
            slotsByDate
              ..clear()
              ..addAll(grouped);
            _loading = false;
          });
        },
        onApiError: (res) => _showError(res),
        onException: (e) => _showError(e.toString()),
      );
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<DateTime?> _pickDate() => showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 90)),
  );

  Future<TimeOfDay?> _pickTime(TimeOfDay initial) =>
      showTimePicker(context: context, initialTime: initial);

  String _format24(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _format12(TimeOfDay t) => t.format(context);

  void _showToast(String msg, {Color bg = Colors.red, position = "center"}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: position == 'top' ? ToastGravity.TOP : ToastGravity.CENTER,
      backgroundColor: bg,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showError(dynamic e) {
    if (!mounted) return;
    setState(() {
      _error = e is String ? e : "Failed to load data";
      _loading = false;
    });
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
      _showToast("End time must be after start time");
      return;
    }

    final newStart = _format24(start);
    final newEnd = _format24(end);
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    if (slotsByDate[date]?.any(
          (s) => s.startTime == newStart && s.endTime == newEnd,
        ) ??
        false) {
      _showToast("A slot already exists with this time!", bg: Colors.orange);
      return;
    }

    await NetworkHelper().safeCall(
      context,
      () => service.createSlot(
        date: formattedDate,
        startTime: newStart,
        endTime: newEnd,
      ),
      onSuccess: (res) {
        final slotId =
            (res['data'] as Map<String, dynamic>?)?['_id'] ??
            (res['data'] as Map<String, dynamic>?)?['id'];
        if (slotId == null) return _showToast("Failed to get slot ID");

        final slot = Slot(
          id: slotId,
          startTime: newStart,
          endTime: newEnd,
          startTimeLabel: _format12(start),
          endTimeLabel: _format12(end),
          dateLabel: DateFormat('d MMM yyyy').format(date),
          date: date,
          available: true,
        );

        setState(() => slotsByDate.putIfAbsent(date, () => []).add(slot));
        _showToast("Slot created successfully", bg: Colors.green);
      },
      onApiError: (res) => _showToast(
        (res as Map<String, dynamic>?)?['message'] ?? "Failed to create slot",
      ),
      onException: (e) => _showToast("Error: $e"),
    );
  }

  void _editSlot(DateTime date, int index) async {
    final slot = slotsByDate[date]![index];
    if (!slot.available) return _showToast("Slot already booked!");

    final start = await _pickTime(const TimeOfDay(hour: 9, minute: 0));
    if (start == null) return;
    final end = await _pickTime(TimeOfDay(hour: start.hour + 1, minute: 0));
    if (end == null || _compareTimes(start, end) >= 0)
      return _showToast("Invalid time range");

    final newStart = _format24(start);
    final newEnd = _format24(end);

    if (slotsByDate[date]!.any(
      (s) => s.id != slot.id && s.startTime == newStart && s.endTime == newEnd,
    )) {
      return _showToast(
        "Another slot already exists with this time!",
        bg: Colors.orange,
      );
    }

    await NetworkHelper().safeCall(
      context,
      () => service.updateSlot(
        slotId: slot.id,
        date: DateFormat('yyyy-MM-dd').format(date),
        startTime: newStart,
        endTime: newEnd,
      ),
      onSuccess: (_) {
        setState(
          () => slotsByDate[date]![index] = slot.copyWith(
            startTime: newStart,
            endTime: newEnd,
            startTimeLabel: _format12(start),
            endTimeLabel: _format12(end),
          ),
        );
        _showToast("Slot updated", bg: Colors.green);
      },
      onApiError: (res) => _showToast(
        (res as Map<String, dynamic>?)?['message'] ?? "Failed to update slot",
      ),
      onException: (e) => _showToast("Error: $e"),
    );
  }

  void _deleteSlot(DateTime date, int index) async {
    final slot = slotsByDate[date]![index];
    if (!slot.available) return _showToast("Cannot delete booked slot");

    final confirmed = await showConfirmationDialog(
      context: context,
      title: "Delete Slot",
      message: "Are you sure you want to delete this slot?",
      confirmText: "Yes",
      cancelText: "No",
      confirmColor: Colors.red,
    );

    if (!confirmed) {
      return;
    }
    await NetworkHelper().safeCall<Map<String, dynamic>>(
      context,
      () => service.deleteSlot(slot.id),
      onSuccess: (res) {
        if (res['success'] == true) {
          setState(() {
            slotsByDate[date]!.removeAt(index);
            if (slotsByDate[date]!.isEmpty) slotsByDate.remove(date);
          });
          _showToast("Slot deleted", bg: Colors.green);
        } else {
          _showToast("Failed to delete slot");
        }
      },
      onApiError: (_) => _showToast("Failed to delete slot"),
      onException: (e) => _showToast("Error: $e"),
    );
  }

  int _compareTimes(TimeOfDay a, TimeOfDay b) =>
      a.hour != b.hour ? a.hour - b.hour : a.minute - b.minute;

  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      loading: _loading,
      error: _error,
      onRetry: _loadSlots,
      child: _buildMainUI(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF6B35),
        onPressed: _addSlot,
        label: const Text("Add Slot"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMainUI() {
    final sortedDates = slotsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return RefreshIndicator(
      onRefresh: () async {
        await _loadSlots();
        _showToast("Slots updated!", bg: Colors.green, position: "top");
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: sortedDates.isEmpty
            ? const Center(
                child: Text(
                  "No slots found",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            : _buildSlotList(sortedDates),
      ),
    );
  }

  Widget _buildSlotList(List<DateTime> sortedDates) {
    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateSlots = slotsByDate[date]!;
        final formattedDate = DateFormat('EEE, MMM d, yyyy').format(date);

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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 2),
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
                            color: isBooked ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: isBooked ? Colors.red : Colors.green,
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
                          onPressed: () =>
                              _editSlot(date, slotsByDate[date]!.indexOf(slot)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () => _deleteSlot(
                            date,
                            slotsByDate[date]!.indexOf(slot),
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
    );
  }
}
