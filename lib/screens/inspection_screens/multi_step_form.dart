import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/screens/inspection_screens/question_item.dart';
import '../../controller/multi_form_controller.dart';
import '../../widgets/video_loader.dart';

final List<String> step1Questions = [
  "foundation_form_f1",
  "foundation_form_f2",
  "foundation_form_f3",
  "foundation_form_f4",
  "foundation_form_f5",
  "foundation_form_f6",
  "foundation_form_f7",
  "foundation_form_f8",
  "foundation_form_f9",
  "foundation_form_f10",
  "foundation_form_f11",
];

final List<String> step2Questions = [
  "post_form_p1",
  "post_form_p2",
  "post_form_p3",
  "post_form_p4",
  "post_form_p5",
  "post_form_p6",
  "post_form_p7",
  "post_form_p8",
  "post_form_p9",
  "post_form_p10",
  "post_form_p11",
  "post_form_p12",
];

final List<String> step3Questions = [
  "adBoard_form_a1",
  "adBoard_form_a2",
  "adBoard_form_a3",
  "adBoard_form_a4",
  "adBoard_form_a5",
  "adBoard_form_a6",
  "adBoard_form_a7",
  "adBoard_form_a8",
  "adBoard_form_a9",
  "adBoard_form_a10",
];

final List<String> step4Questions = [
  "safety_form_s1",
  "safety_form_s2",
  "safety_form_s3",
  "safety_form_s4",
  "safety_form_s5",
  "safety_form_s6",
  "safety_form_s7",
];

final List<List<String>> allSteps = [
  step1Questions,
  step2Questions,
  step3Questions,
  step4Questions,
];

class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  final List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final controller = Get.find<MultiFormController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Image.asset(
                    'assets/images/adinn_logo.png',
                    height: 40,
                  ),
                ),
              ],
            ),
            stepHeader(),
            Expanded(
              child: Obx(() {
                /* if (!controller.isInspectionLoaded.value) {
                  return const Center(child: CircularProgressIndicator());
                }*/
                if (!controller.isInspectionLoaded.value) {
                  return VideoLoader();
                }
                return Form(
                  key: formKeys[controller.currentStep.value],
                  child: stepBody(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget stepHeader() {
    List<String> steps = [
      "foundation_form_title",
      "post_form_title",
      "adBoard_form_title",
      "safety_form_title",
    ];

    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.goToStep(index),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: controller.currentStep.value >= index
                              ? Colors.green
                              : Colors.grey,
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            steps[index].tr,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 9,
                              overflow: TextOverflow.ellipsis,
                              color: controller.currentStep.value >= index
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: controller.currentStep.value >= index
                                  ? FontWeight.w500
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget stepBody() {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return stepOne();
        case 1:
          return stepTwo();
        case 2:
          return stepThree();
        case 3:
          return stepFour();
        default:
          return Container();
      }
    });
  }

  Widget stepButtons() {
    return Obx(() {
      int step = controller.currentStep.value;

      if (controller.isAnyUploading) {
        return const SizedBox();
      }
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.prevStep,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          Colors.white.withOpacity(0.5),
                        ),
                      ),
                  child: Text(
                    "back_button".tr,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (step > 0) const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (step == 3) {
                    Get.toNamed('/submitScreen');
                  } else {
                    controller.nextStep(formKeys[step]);
                  }
                },
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.white.withOpacity(0.5),
                      ),
                    ),
                child: Text(
                  "next_button".tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget stepOne() {
    return stepWidget(questions: step1Questions, startIndex: getStartIndex(0));
  }

  Widget stepTwo() {
    return stepWidget(questions: step2Questions, startIndex: getStartIndex(1));
  }

  Widget stepThree() {
    return stepWidget(questions: step3Questions, startIndex: getStartIndex(2));
  }

  Widget stepFour() {
    return stepWidget(questions: step4Questions, startIndex: getStartIndex(3));
  }

  int getStartIndex(int stepIndex) {
    int start = 0;
    for (int i = 0; i < stepIndex; i++) {
      start += allSteps[i].length;
    }
    return start;
  }

  Widget stepWidget({
    required List<String> questions,
    required int startIndex,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              buildQuestionList(questions: questions, startIndex: startIndex),
              stepButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildQuestionList({
  required List<String> questions,
  required int startIndex,
}) {
  final controller = Get.find<MultiFormController>();

  return Column(
    children: List.generate(questions.length, (i) {
      int index = startIndex + i;

      return QuestionItem(
        question: questions[i].tr,
        controller: controller.controllers[index],
        widgetIndex: index,
      );
    }),
  );
}
