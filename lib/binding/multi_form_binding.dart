import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:unipole_inspection/controller/multi_form_controller.dart';

class MultiFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MultiFormController());
  }
}
