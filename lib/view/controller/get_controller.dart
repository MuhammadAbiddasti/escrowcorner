import 'package:get/get.dart';

class CheckboxController extends GetxController {
  var isChecked = false.obs;
  void toggleDialogVisibility() {
    isChecked.value = !isChecked.value;
  }


}
class MenubuttonController extends GetxController {
  var selectedOption = "Today".obs;
  var isWalletCreated  = false.obs;

  void updateSelectedOption(String option) {
    selectedOption.value = option;
  }

  void createWallet() {
    isWalletCreated.value = true;
  }

  void goBack() {
    isWalletCreated.value = false;
  }
}
class InfoController extends GetxController {
  var isVisible = true.obs;

  void hideContainer() {
    isVisible.value = false;
  }
}


