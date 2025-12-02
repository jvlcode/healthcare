import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../../services/upload_service.dart';
import '../../../../../services/doctor_service.dart';
import '../../../../../app/session/session_manager.dart';
import '../../../../../app/app_routes.dart';
import '../../../../../core/constants/urls.dart';
import '../utils/application_validators.dart';

/// Small feature-local model
class DoctorApplicationData {
  String fullName = '';
  String email = '';
  String phone = '';
  String qualification = '';
  String specialization = '';
  int experienceYears = 0;

  String clinicName = '';
  String clinicAddress = '';

  List<Map<String, String>> uploadedDocuments = [];

  Map<String, dynamic> toStep1() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'qualifications': qualification,
    'specialization': specialization,
    'experienceYears': experienceYears,
  };

  Map<String, dynamic> toStep2() => {
    'clinicName': clinicName,
    'clinicAddress': clinicAddress,
  };

  Map<String, dynamic> toStep3() => {"documents": uploadedDocuments};

  Map<String, dynamic> toJson() => {
    ...toStep1(),
    ...toStep2(),
    'documents': uploadedDocuments,
  };
}

class ApplicationController extends ChangeNotifier {
  static const _boxName = 'doctor_application';

  int currentStep = 0;
  bool isLoading = false;
  bool showValidationErrors = false;

  final DoctorApplicationData data = DoctorApplicationData();

  // controllers
  late final TextEditingController fullNameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController qualificationCtrl;
  late final TextEditingController specializationCtrl;
  late final TextEditingController experienceCtrl;

  late final TextEditingController clinicNameCtrl;
  late final TextEditingController clinicAddressCtrl;

  final List<PlatformFile> pickedFiles = [];

  late final Box _box;

  final _uploadService = UploadService();
  final _doctorService = DoctorService();

  Future<void> init() async {
    _box = Hive.box(_boxName);

    final s1 = _box.get('personalInfo') as Map?;
    final s2 = _box.get('clinicInfo') as Map?;

    final docsRaw = _box.get('documents') as List?;
    final docs =
        docsRaw?.map((e) => Map<String, String>.from(e as Map)).toList() ?? [];

    if (s1 != null) {
      data.fullName = s1['fullName'] ?? '';
      data.email = s1['email'] ?? '';
      data.phone = s1['phone'] ?? '';
      data.qualification = s1['qualifications'] ?? '';
      data.specialization = s1['specialization'] ?? '';
      data.experienceYears = s1['experienceYears'] ?? 0;
    }

    if (s2 != null) {
      data.clinicName = s2['clinicName'] ?? '';
      data.clinicAddress = s2['clinicAddress'] ?? '';
    }

    data.uploadedDocuments = docs;

    fullNameCtrl = TextEditingController(text: data.fullName)
      ..addListener(() {
        data.fullName = fullNameCtrl.text;
        _saveStep1();
      });

    emailCtrl = TextEditingController(text: data.email)
      ..addListener(() {
        data.email = emailCtrl.text;
        _saveStep1();
      });

    phoneCtrl = TextEditingController(text: data.phone)
      ..addListener(() {
        data.phone = phoneCtrl.text;
        _saveStep1();
      });

    qualificationCtrl = TextEditingController(text: data.qualification)
      ..addListener(() {
        data.qualification = qualificationCtrl.text;
        _saveStep1();
      });

    specializationCtrl = TextEditingController(text: data.specialization)
      ..addListener(() {
        data.specialization = specializationCtrl.text;
        _saveStep1();
      });

    experienceCtrl =
        TextEditingController(
          text: data.experienceYears == 0
              ? ''
              : data.experienceYears.toString(),
        )..addListener(() {
          data.experienceYears = int.tryParse(experienceCtrl.text) ?? 0;
          _saveStep1();
        });

    clinicNameCtrl = TextEditingController(text: data.clinicName)
      ..addListener(() {
        data.clinicName = clinicNameCtrl.text;
        _saveStep2();
      });

    clinicAddressCtrl = TextEditingController(text: data.clinicAddress)
      ..addListener(() {
        data.clinicAddress = clinicAddressCtrl.text;
        _saveStep2();
      });

    notifyListeners();
  }

  Future<void> _saveStep1() async {
    await _box.put('personalInfo', data.toStep1());
  }

  Future<void> _saveStep2() async {
    await _box.put('clinicInfo', data.toStep2());
  }

  Future<void> _saveStep3() async {
    await _box.put('documents', data.uploadedDocuments);
  }

  void goToStep(int i) {
    if (i <= currentStep) {
      currentStep = i;
      notifyListeners();
      return;
    }

    if (_validateCurrentStep()) {
      currentStep = i;
    } else {
      showValidationErrors = true;
    }
    notifyListeners();
  }

  void onBack(BuildContext context) {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> onContinue(BuildContext context) async {
    showValidationErrors = true;
    notifyListeners();

    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields')),
      );
      return;
    }

    if (currentStep < 3) {
      currentStep++;
      notifyListeners();
      return;
    }

    await submitApplication(context);
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return ApplicationValidators.validatePersonal(
          fullName: data.fullName,
          email: data.email,
          phone: data.phone,
          qualification: data.qualification,
          specialization: data.specialization,
          experience: data.experienceYears,
        );

      case 1:
        return ApplicationValidators.validateClinic(
          clinicName: data.clinicName,
          clinicAddress: data.clinicAddress,
        );

      case 2:
        return ApplicationValidators.validateDocuments(
          data.uploadedDocuments,
          pickedFiles: pickedFiles,
        );

      case 3:
        return ApplicationValidators.validatePersonal(
              fullName: data.fullName,
              email: data.email,
              phone: data.phone,
              qualification: data.qualification,
              specialization: data.specialization,
              experience: data.experienceYears,
            ) &&
            ApplicationValidators.validateClinic(
              clinicName: data.clinicName,
              clinicAddress: data.clinicAddress,
            ) &&
            ApplicationValidators.validateDocuments(
              data.uploadedDocuments,
              pickedFiles: pickedFiles,
            );

      default:
        return false;
    }
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      pickedFiles.addAll(result.files);
      notifyListeners();
    }
  }

  Future<void> uploadPickedFiles(BuildContext context) async {
    if (pickedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No files selected')));
      return;
    }

    isLoading = true;
    notifyListeners();

    final uploaded = <Map<String, String>>[];
    final failed = <String>[];

    for (final pf in List<PlatformFile>.from(pickedFiles)) {
      final path = pf.path;
      if (path == null) continue;

      try {
        final resp = await _uploadService.uploadDocument(File(path));
        final url = resp['url'];
        if (url != null) {
          uploaded.add({'name': pf.name, 'url': '${AppUrls.baseUrl}$url'});
        } else {
          failed.add(pf.name);
        }
      } catch (_) {
        failed.add(pf.name);
      }
    }

    data.uploadedDocuments.addAll(uploaded);
    await _saveStep3();

    pickedFiles.clear();
    isLoading = false;
    notifyListeners();

    if (failed.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: ${failed.join(", ")}')),
      );
    }
  }

  Future<void> removeUploadedDocument(int index) async {
    if (index < 0 || index >= data.uploadedDocuments.length) return;

    data.uploadedDocuments.removeAt(index);
    await _saveStep3();
    notifyListeners();
  }

  Future<void> submitApplication(BuildContext context) async {
    if (!_validateCurrentStep()) {
      showValidationErrors = true;
      notifyListeners();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Complete all steps first')));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final result = await _doctorService.submitApplication(
        personalInfo: data.toStep1(),
        clinicInfo: data.toStep2(),
        documents: data.uploadedDocuments,
      );

      if (result is Map && result['success'] == true) {
        await SessionManager.setDoctorApproved(false);

        final d = result['data']?['doctor'];
        if (d != null) {
          final current = await SessionManager.getCurrentUser();
          if (current != null) {
            await SessionManager.updateUser(current.copyWith(doctor: d));
          }
        }

        await _box.clear();

        if (context.mounted) {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application submitted')),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.doctorHome,
            (r) => false,
          );
        }
      } else {
        if (context.mounted) {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Submission failed: ${result['message'] ?? 'Unknown error'}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> clearDraft() async {
    await _box.delete('personalInfo');
    await _box.delete('clinicInfo');
    await _box.delete('documents');
    data.uploadedDocuments.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    qualificationCtrl.dispose();
    specializationCtrl.dispose();
    experienceCtrl.dispose();
    clinicNameCtrl.dispose();
    clinicAddressCtrl.dispose();
    super.dispose();
  }
}
