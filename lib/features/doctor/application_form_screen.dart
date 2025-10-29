// lib/main.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/* ------------------------
   1) Doctor Application Form
   ------------------------ */
class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _qualification = TextEditingController();
  final _specialization = TextEditingController();
  final _experience = TextEditingController();
  final _clinic = TextEditingController();
  final _bio = TextEditingController();
  File? _profileImage;

  Future<void> _pickProfileImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      // store data locally or pass via arguments; here we simply navigate
      Navigator.pushNamed(context, '/terms');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _qualification.dispose();
    _specialization.dispose();
    _experience.dispose();
    _clinic.dispose();
    _bio.dispose();
    super.dispose();
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Application')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // avatar
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const NetworkImage(
                                'https://cdn-icons-png.flaticon.com/512/1077/1077114.png',
                              )
                              as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF01312F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _field(_name, 'Full name'),
                const SizedBox(height: 12),
                _field(
                  _email,
                  'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _field(_phone, 'Phone', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _field(_qualification, 'Qualification'),
                const SizedBox(height: 12),
                _field(_specialization, 'Specialization'),
                const SizedBox(height: 12),
                _field(
                  _experience,
                  'Experience (years)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _field(_clinic, 'Clinic / Hospital'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bio,
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                  decoration: InputDecoration(
                    labelText: 'Short bio',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF01312F),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Next — Terms',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------
   2) Terms & Conditions Ack + Video
   ------------------------ */
class TermsAckScreen extends StatefulWidget {
  const TermsAckScreen({super.key});

  @override
  State<TermsAckScreen> createState() => _TermsAckScreenState();
}

class _TermsAckScreenState extends State<TermsAckScreen> {
  bool _accepted = false;
  late VideoPlayerController _controller;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Example short video - replace with your own T&C video (network or asset)
    _controller =
        VideoPlayerController.network(
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          )
          ..initialize().then((_) {
            setState(() => _videoInitialized = true);
            _controller.setLooping(false);
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_accepted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please accept terms')));
      return;
    }
    Navigator.pushNamed(context, '/upload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Please watch this short video and accept the terms to continue.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Video player box
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _videoInitialized
                  ? Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: VideoProgressIndicator(
                                  _controller,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: const [
                        Text(
                          'Short Terms & Conditions (summary)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Provide accurate credentials.\n'
                          '2. Follow patient privacy rules.\n'
                          '3. Your availability must be accurate.\n'
                          '4. Appointments once booked cannot be modified by you if already taken.\n\n'
                          'Read the full terms in the backend or PDF (link).',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            CheckboxListTile(
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
              title: const Text(
                'I have watched the video and accept the Terms',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Continue', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/* ------------------------
   3) Certificate Upload Screen
   ------------------------ */
class CertificateUploadScreen extends StatefulWidget {
  const CertificateUploadScreen({super.key});

  @override
  State<CertificateUploadScreen> createState() =>
      _CertificateUploadScreenState();
}

class _CertificateUploadScreenState extends State<CertificateUploadScreen> {
  final List<PlatformFile> _files = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _files.addAll(result.files));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (picked != null) {
      final file = PlatformFile(
        name: picked.name,
        size: await File(picked.path).length(),
        path: picked.path,
      );
      setState(() => _files.add(file));
    }
  }

  void _submit() {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one document')),
      );
      return;
    }
    // Here you would upload to server. We simulate by navigating to pending screen.
    Navigator.pushReplacementNamed(context, '/pending');
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Certificates')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Upload medical license, degree or other certificates.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Select Files'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01312F),
                  ),
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _files.isEmpty
                  ? const Center(child: Text('No files selected'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, i) {
                        final f = _files[i];
                        return Card(
                          child: ListTile(
                            leading:
                                f.extension != null &&
                                    (f.extension!.toLowerCase() == 'jpg' ||
                                        f.extension!.toLowerCase() == 'png' ||
                                        f.extension!.toLowerCase() == 'jpeg')
                                ? Image.file(
                                    File(f.path!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.picture_as_pdf, size: 40),
                            title: Text(f.name),
                            subtitle: Text(
                              '${(f.size / 1024).toStringAsFixed(1)} KB',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeFile(i),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF01312F),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Submit for Approval',
                        style: TextStyle(fontSize: 16),
                      ),
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

/* ------------------------
   4) Approval Pending Screen
   ------------------------ */
class ApprovalPendingScreen extends StatelessWidget {
  const ApprovalPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pending')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.hourglass_top, size: 80, color: Color(0xFF01312F)),
            const SizedBox(height: 16),
            const Text(
              'Your documents are under review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will review your application and documents within 24-48 hours. You will be notified once your account is approved.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // In a real app, we would check status from backend. For demo, go to slots to simulate approval.
                Navigator.pushReplacementNamed(context, '/slots');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01312F),
              ),
              child: const Text('Simulate Approved — Go to Slots'),
            ),
          ],
        ),
      ),
    );
  }
}

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
