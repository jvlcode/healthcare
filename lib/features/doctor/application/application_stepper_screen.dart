import 'package:flutter/material.dart';
import 'controllers/application_controller.dart';
import 'widgets/step_personal.dart';
import 'widgets/step_clinic.dart';
import 'widgets/step_documents.dart';
import 'widgets/step_review.dart';

class ApplicationStepperScreen extends StatefulWidget {
  const ApplicationStepperScreen({super.key});

  @override
  State<ApplicationStepperScreen> createState() =>
      _ApplicationStepperScreenState();
}

class _ApplicationStepperScreenState extends State<ApplicationStepperScreen> {
  late final ApplicationController controller;

  final Color _primaryColor = const Color(0xFF01312F);

  @override
  void initState() {
    super.initState();
    controller = ApplicationController()..init();
    controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdate);
    controller.dispose();
    super.dispose();
  }

  Widget _stepTitle(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  @override
  Widget build(BuildContext context) {
    final steps = [
      Step(
        title: _stepTitle('Personal'),
        content: StepPersonal(controller: controller),
        isActive: controller.currentStep >= 0,
        state: controller.currentStep > 0
            ? StepState.complete
            : StepState.indexed,
      ),
      Step(
        title: _stepTitle('Clinic'),
        content: StepClinic(controller: controller),
        isActive: controller.currentStep >= 1,
        state: controller.currentStep > 1
            ? StepState.complete
            : StepState.indexed,
      ),
      Step(
        title: _stepTitle('Docs'),
        content: StepDocuments(controller: controller),
        isActive: controller.currentStep >= 2,
        state: controller.currentStep > 2
            ? StepState.complete
            : StepState.indexed,
      ),
      Step(
        title: _stepTitle('Review'),
        content: StepReview(controller: controller),
        isActive: controller.currentStep >= 3,
        state: controller.currentStep == 3
            ? StepState.editing
            : StepState.indexed,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Application'),
        backgroundColor: _primaryColor,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stepper(
                  physics: const ClampingScrollPhysics(),
                  currentStep: controller.currentStep,
                  onStepTapped: (i) => controller.goToStep(i),
                  onStepContinue: () => controller.onContinue(context),
                  onStepCancel: () => controller.onBack(context),
                  controlsBuilder: (context, details) {
                    final isLast = controller.currentStep == steps.length - 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(isLast ? 'Submit' : 'Next'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: steps,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // overlay loader
          if (controller.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
