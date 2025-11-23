import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'meal_scan_controller.dart';

class MealScanView extends GetView<MealScanController> {
  const MealScanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 120,
              color: AppColors.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              'Scan Your Meal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Take a photo or upload from gallery to get instant nutrition analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            Obx(() => CustomButton(
              text: 'Take Photo',
              icon: Icons.camera_alt,
              onPressed: controller.scanFromCamera,
              isLoading: controller.isScanning.value,
            )),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Choose from Gallery',
              icon: Icons.photo_library,
              onPressed: controller.scanFromGallery,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
