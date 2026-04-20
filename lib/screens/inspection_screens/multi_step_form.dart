import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:unipole_inspection/screens/inspection_screens/question_item.dart';
import '../../controller/multi_form_controller.dart';

class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  final TextEditingController issueController = TextEditingController();

  final List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final controller = Get.put(MultiFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Image.asset('assets/images/adinn_logo.png', height: 40),
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              QuestionItem(question: "1. Are there cracks in the concrete?"),
              QuestionItem(question: "2. Is the foundation slab loose?"),
              QuestionItem(question: "3. Is there rust on the anchor bolts?"),
              QuestionItem(question: "4. Are the anchor plates corroded?"),
              QuestionItem(question: "5. Is the foundation grout damanged?"),
              QuestionItem(question: "6. Is the ground/soil settled?"),
              QuestionItem(question: "7. Is Water pooling around the base?"),
              QuestionItem(question: "8. Is the Unipole leaning at the base?"),
              QuestionItem(question: "9. Are the welding joints cracked?"),
              QuestionItem(
                question: "10. Is the concrete base disintegrating?",
              ),
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              QuestionItem(
                question: "1. Is the post straight and properly aligned?",
              ),
              QuestionItem(
                question: "2. Is there any damage or crack in the post?",
              ),
              QuestionItem(
                question: "3. Is there rust present on the post surface?",
              ),
              QuestionItem(
                question: "4. Are the bolts and nuts properly tightened?",
              ),
              QuestionItem(
                question: "5. Are the bolts and nuts free from corrosion?",
              ),
              QuestionItem(
                question: "6. Is the post firmly fixed without movement?",
              ),
              QuestionItem(
                question: "7. Is the paint condition of the post good?",
              ),
              QuestionItem(
                question: "8. Is the ladder condition safe and usable?",
              ),
              QuestionItem(
                question: "9. Is the lightning arrestor properly installed?",
              ),
              QuestionItem(
                question:
                    "10. Is the earthing connection available and proper?",
              ),
              QuestionItem(
                question: "11. Is the platform condition safe and stable?",
              ),
              QuestionItem(
                question: "12. Is the platform free from damage or cracks?",
              ),
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              QuestionItem(question: "1. Is the frame straight?"),
              QuestionItem(question: "2. Is there any bending in the frame?"),
              QuestionItem(
                question: "3. Are the angles/wires aligned properly?",
              ),
              QuestionItem(question: "4. Are the weld joints proper/aligned?"),
              QuestionItem(question: "5. Are the panels fitted properly?"),
              QuestionItem(question: "6. Are the panels loose?"),
              QuestionItem(question: "7. Are the clamps tight?"),
              QuestionItem(question: "8. Are the fasteners loose?"),
              QuestionItem(question: "9. Is there vibration due to wind?"),
              QuestionItem(question: "10. Is there water leakage?"),
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            children: [
              QuestionItem(question: "1. Is the surrounding area safe?"),
              QuestionItem(
                question: "2. Are there nearby electrical wires touching?",
              ),
              QuestionItem(
                question: "3. Are the angles/wires aligned properly?",
              ),
              QuestionItem(question: "4. Are the weld joints proper/aligned?"),
              QuestionItem(question: "5. Are the panels fitted properly?"),
              QuestionItem(question: "6. Are the panels loose?"),
              QuestionItem(question: "7. Are the clamps tight?"),
              QuestionItem(question: "8. Are the fasteners loose?"),
              QuestionItem(question: "9. Is there vibration due to wind?"),
              QuestionItem(question: "10. Is there water leakage?"),
              stepButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
