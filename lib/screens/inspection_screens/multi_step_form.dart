import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:unipole_inspection/screens/inspection_screens/question_item.dart';
import '../../controller/multi_form_controller.dart';

final List<String> step1Questions = [
  "1. Are there any cracks in the concrete?",
  "2. Is there any soil erosion at the foundation?",
  "3. Is there any water stagnation?",
  "4. Is there any looseness in the anchor bolts?",
  "5. Are the anchor bolts rusted?",
  "6. Is the base plate properly seated?",
  "7. Is there any gap in the base plate?",
  "8. Is the grouting damaged?",
  "9. Is the foundation tilted?",
  "10. Has foundation settlement occurred?",
  "11. Is the surrounding soil loose?",
];

final List<String> step2Questions = [
  "1. Is the post straight?",
  "2. Is the post tilted?",
  "3. Is there any bend in the post?",
  "4. Is there any crack in the welded joint?",
  "5. Is there any damage in the welded joint?",
  "6. Is there rust?",
  "7. Has the paint peeled off?",
  "8. Has the post thickness reduced?",
  "9. Are the splice bolts tight?",
  "10. Is there any looseness in the splice nuts?",
  "11. Is the ladder secure?",
  "12. Is the platform strong?",
];

final List<String> step3Questions = [
  "1. Is the frame straight?",
  "2. Is there any bend in the frame?",
  "3. Are the angle / pipe members strong?",
  "4. Are the welded joints strong?",
  "5. Is the flex properly fixed?",
  "6. Is the flex loose?",
  "7. Are the clamps tight?",
  "8. Is there any looseness in the support fasteners?",
  "9. Is there vibration due to wind?",
  "10.Is there water runoff / seepage on the structure?",
];

final List<String> step4Questions = [
  "1. Is the surrounding area safe?",
  "2. Are nearby trees touching the structure?",
  "3. Are there any obstructions?",
  "4. Is there any wind damage?",
  "5. Is there any rain damage?",
  "6. Are there any unauthorized modifications?",
  "7. Have repairs been carried out properly?",
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
    List<String> steps = ["Foundation", "Post", "Ad Board", "Safety"];

    return Obx(() {
      return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () => controller.goToStep(index),
              child: Column(
                children: [
                  Row(
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
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: controller.currentStep.value >= index
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
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

      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.prevStep,
                  child: const Text("Back"),
                ),
              ),
            if (step > 0) const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => controller.nextStep(formKeys[step]),
                child: Text(step == 3 ? "Submit" : "Next"),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget stepOne() {
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
              buildQuestionList(questions: step1Questions, startIndex: 0),
              stepButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget stepTwo() {
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
              buildQuestionList(questions: step2Questions, startIndex: 11),
              stepButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget stepThree() {
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
              buildQuestionList(questions: step3Questions, startIndex: 23),
              stepButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget stepFour() {
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
              buildQuestionList(questions: step4Questions, startIndex: 33),
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
        question: questions[i],
        controller: controller.controllers[index],
        widgetIndex: index,
      );
    }),
  );
}
