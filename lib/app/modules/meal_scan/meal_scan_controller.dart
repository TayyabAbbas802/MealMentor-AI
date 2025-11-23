import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MealScanController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final isScanning = false.obs;

  void scanFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _analyzeMeal(photo.path);
    }
  }

  void scanFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _analyzeMeal(image.path);
    }
  }

  void _analyzeMeal(String imagePath) async {
    isScanning.value = true;
    await Future.delayed(const Duration(seconds: 3));
    isScanning.value = false;

    Get.snackbar(
      'Success',
      'Meal analyzed successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
