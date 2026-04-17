import 'package:flutter/material.dart';
import 'package:unipole_inspection/screens/multi_step_form.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController visitedByController = TextEditingController(
    text: "Sathish",
  );
  String heightUnit = "ft";
  String sizeUnit = "ft";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/adinn_logo.png', height: 40),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Tamil clicked");
                            },
                            child: const Text(
                              "தமிழ்",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text("|"),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              print("English clicked");
                            },
                            child: const Text(
                              "English",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Fill Inspection Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter unipole details to start inspection",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      buildTextField(
                        label: "Unipole Height",
                        hint: "Enter height",
                        icon: Icons.height,
                        controller: heightController,
                        suffixWidget: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildUnit(
                                unit: "ft",
                                selectedUnit: heightUnit,
                                onChanged: (val) {
                                  setState(() {
                                    heightUnit = val;
                                  });
                                },
                              ),
                              buildUnit(
                                unit: "inch",
                                selectedUnit: heightUnit,
                                onChanged: (val) {
                                  setState(() {
                                    heightUnit = val;
                                  });
                                },
                              ),
                              buildUnit(
                                unit: "cm",
                                selectedUnit: heightUnit,
                                onChanged: (val) {
                                  setState(() {
                                    heightUnit = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Ad Structure Size",
                        hint: "Enter size (W x H)",
                        icon: Icons.aspect_ratio,
                        controller: sizeController,
                        suffixWidget: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildUnit(
                                unit: "ft",
                                selectedUnit: sizeUnit,
                                onChanged: (val) {
                                  setState(() {
                                    sizeUnit = val;
                                  });
                                },
                              ),
                              buildUnit(
                                unit: "inch",
                                selectedUnit: sizeUnit,
                                onChanged: (val) {
                                  setState(() {
                                    sizeUnit = val;
                                  });
                                },
                              ),
                              buildUnit(
                                unit: "cm",
                                selectedUnit: sizeUnit,
                                onChanged: (val) {
                                  setState(() {
                                    sizeUnit = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Visiting Date",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.red),
                            Text("26 April 2025"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      buildTextField(
                        label: "Visited By",
                        hint: "Enter name",
                        icon: Icons.person,
                        controller: visitedByController,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            print("Height: ${heightController.text}");
                            print("Size: ${sizeController.text}");
                            print("Date: ${dateController.text}");
                            print("Visited By: ${visitedByController.text}");
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MultiStepForm(),));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ?suffixWidget,
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red),
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUnit({
    required String unit,
    required String selectedUnit,
    required Function(String) onChanged,
  }) {
    final isSelected = selectedUnit == unit;

    return GestureDetector(
      onTap: () {
        setState(() {
          onChanged(unit);
        });
        print("$unit clicked");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
