import 'package:flutter/material.dart';

class MultiStepForm extends StatefulWidget {
  const MultiStepForm({super.key});

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int currentStep = 0;

  final TextEditingController issueController = TextEditingController();

  final List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  void nextStep() {
    if (formKeys[currentStep].currentState!.validate()) {
      if (currentStep < 3) {
        setState(() => currentStep++);
      }
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

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
              child: Form(key: formKeys[currentStep], child: stepBody()),
            ),
          ],
        ),
      ),
    );
  }

  Widget stepHeader() {
    List<String> steps = ["Foundation", "Post", "Ad Board", "Safety"];

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
          return Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: currentStep >= index
                        ? Colors.red
                        : Colors.grey,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: currentStep >= index ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget stepBody() {
    switch (currentStep) {
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
  }

  Widget stepButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: prevStep,
                child: const Text("Back"),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: nextStep,
              child: Text(currentStep == 3 ? "Submit" : "Next"),
            ),
          ),
        ],
      ),
    );
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
              QuestionItem(question: "2. Are there nearby electrical wires touching?"),
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

class QuestionItem extends StatefulWidget {
  final String question;

  const QuestionItem({super.key, required this.question});

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  bool isYesSelected = false;

  @override
  Widget build(BuildContext context) {
    return /*Padding(
      padding: const EdgeInsets.all(10),
      child:*/ /*Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),

        child:*/ Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /*const SizedBox(height: 10),*/
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// YES
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isYesSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isYesSelected
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: isYesSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  /// NO
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isYesSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: !isYesSelected
                            ? Colors.grey.shade300
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: !isYesSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// Issue Container
        if (isYesSelected)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Write issue details",
                    border: InputBorder.none,
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.camera_alt, size: 18),
                          SizedBox(width: 5),
                          Text("Image"),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.camera_alt, size: 18),
                          SizedBox(width: 5),
                          Text("Video"),
                        ],
                      ),
                    ),
                  ],
                ),
                //Divider(),
                SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      "• Live Camera Only",
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "• No gallery Upload",
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "• Maximum 10 files",
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
