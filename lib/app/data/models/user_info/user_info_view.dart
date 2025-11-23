import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_info_controller.dart';

class UserInfoView extends GetView<UserInfoController> {
  const UserInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: controller.skipForNow,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us personalize your meal recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Progress indicator
                _buildProgressIndicator(),
                const SizedBox(height: 32),

                // Weight Input
                _buildSectionTitle('Weight'),
                const SizedBox(height: 12),
                _buildWeightInput(),
                const SizedBox(height: 24),

                // Height Input
                _buildSectionTitle('Height'),
                const SizedBox(height: 12),
                _buildHeightInput(),
                const SizedBox(height: 32),

                // Goal Selection
                _buildSectionTitle('What\'s Your Goal?'),
                const SizedBox(height: 12),
                _buildGoalSelection(),
                const SizedBox(height: 32),

                // BMI Preview
                _buildBMIPreview(),
                const SizedBox(height: 32),

                // Continue Button
                _buildContinueButton(),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: 0.8,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          '80%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your weight',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.weightUnit.value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildHeightInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter your height',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.heightUnit.value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildGoalSelection() {
    return Column(
      children: controller.goals.map((goal) {
        final isSelected = controller.selectedGoal.value == goal['title'];
        return GestureDetector(
          onTap: () => controller.selectGoal(goal['title']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withOpacity(0.1)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.grey!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goal['icon'],
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBMIPreview() {
    if (controller.weightController.text.isEmpty ||
        controller.heightController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final weight = double.parse(controller.weightController.text);
      final height = double.parse(controller.heightController.text);
      final bmi = weight / ((height / 100) * (height / 100));

      String category;
      Color categoryColor;

      if (bmi < 18.5) {
        category = 'Underweight';
        categoryColor = Colors.blue;
      } else if (bmi < 25) {
        category = 'Normal';
        categoryColor = Colors.green;
      } else if (bmi < 30) {
        category = 'Overweight';
        categoryColor = Colors.orange;
      } else {
        category = 'Obese';
        categoryColor = Colors.red;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withOpacity(0.1),
              categoryColor.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: categoryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.health_and_safety, color: categoryColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your BMI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bmi.toStringAsFixed(1)} - $category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveUserInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
