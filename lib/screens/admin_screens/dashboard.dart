import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:unipole_inspection/controller/dashboard_controller.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.dashboardData.value?.data;

        if (data == null) {
          return const Center(child: Text("No data found"));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  padding: EdgeInsets.all(10),
                  children: [
                    statCard(
                      "Verified Users",
                      data.verifiedCount.toString(),
                      Colors.green,
                      Icons.people,
                    ),
                    statCard(
                      "Unverified Users",
                      data.unverifiedCount.toString(),
                      Colors.red,
                      Icons.people,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    "Inspection Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 5,
                  padding: EdgeInsets.all(10),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/adminInspectionScreen');
                      },
                      child: inspectionCard(
                        "Total",
                        data.inspectionTotalCount.toString(),
                        Colors.blue,
                        Icons.assignment,
                      ),
                    ),
                    inspectionCard(
                      "Completed",
                      data.inspectionCompletedCount.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                    inspectionCard(
                      "In Progress",
                      data.inspectionInProgressCount.toString(),
                      Colors.orange,
                      Icons.access_time,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Users List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.users.length,
                  itemBuilder: (context, index) {
                    final user = data.users[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.phone,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            user.isPhoneVerified ? Icons.circle : Icons.circle,
                            color: user.isPhoneVerified
                                ? Colors.green
                                : Colors.red,
                            size: user.isPhoneVerified ? 12 : 11,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

Widget statCard(String title, String value, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 25, color: color),
            const SizedBox(width: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(title),
      ],
    ),
  );
}

Widget inspectionCard(String title, String value, Color color, IconData icon) {
  return Container(
    padding: EdgeInsets.only(top: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(.15),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    ),
  );
}
