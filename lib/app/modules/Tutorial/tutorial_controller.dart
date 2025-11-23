import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class TutorialController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  final List<TutorialPage> pages = [
    TutorialPage(
      icon: Icons.camera_alt,
      iconColor: const Color(0xFF00D09C),
      title: 'Snap & Track',
      description:
      'Take a photo of your meal and get instant calorie and nutrition information powered by AI',
    ),
    TutorialPage(
      icon: Icons.chat_bubble_outline,
      iconColor: const Color(0xFF7C3AED),
      title: 'AI Diet Coach',
      description:
      'Chat with Gemini AI to get personalized diet plans tailored to your goals and preferences',
    ),
    TutorialPage(
      icon: Icons.fitness_center,
      iconColor: const Color(0xFFFF6B35),
      title: 'Smart Workouts',
      description:
      'Receive exercise recommendations that complement your diet for optimal results',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to signup on last page
      Get.offAllNamed(AppRoutes.SIGNUP);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipTutorial() {
    Get.offAllNamed(AppRoutes.SIGNUP);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class TutorialPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  TutorialPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
