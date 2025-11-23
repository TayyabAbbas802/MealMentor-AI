import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'tutorial_controller.dart';

class TutorialView extends GetView<TutorialController> {
  const TutorialView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MealMentor AI',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: controller.skipTutorial,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: controller.pages.length,
              itemBuilder: (context, index) {
                return _buildPage(controller.pages[index]);
              },
            ),
          ),
          // Page indicators
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                    (index) => _buildIndicator(
                  isActive: index == controller.currentPage.value,
                  color: controller.pages[index].iconColor,
                ),
              ),
            ),
          )),
          // Next/Get Started button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Obx(() {
              bool isLastPage = controller.currentPage.value == controller.pages.length - 1;
              return SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isLastPage
                        ? const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF3B3B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                        : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastPage
                          ? Colors.transparent
                          : controller.pages[controller.currentPage.value].iconColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          // Previous button
          Obx(() => controller.currentPage.value > 0
              ? Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
            child: TextButton.icon(
              onPressed: controller.previousPage,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text(
                'Previous',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          )
              : const SizedBox(height: 56)),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildIndicator({required bool isActive, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
