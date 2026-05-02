import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../auth_service.dart';
import '../model/dashboard_model.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var dashboardData = Rxn<DashboardModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;

      final result = await AuthService().getDashBoard();

      dashboardData.value = result;
    } catch (e) {
      print("Dashboard Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
