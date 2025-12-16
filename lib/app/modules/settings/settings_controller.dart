import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/firebase_service.dart';
import '../../theme/app_colors.dart';

class SettingsController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Notification preferences
  final workoutReminders = true.obs;
  final mealReminders = true.obs;
  final progressUpdates = true.obs;
  
  // Privacy settings
  final dataSharing = false.obs;
  final profileVisibility = true.obs;
  
  final isLoading = false.obs;
  
  // Text controllers for forms
  final supportMessageController = TextEditingController();
  final bugDescriptionController = TextEditingController();
  final bugStepsController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }
  
  @override
  void onClose() {
    supportMessageController.dispose();
    bugDescriptionController.dispose();
    bugStepsController.dispose();
    super.onClose();
  }
  
  void _loadSettings() async {
    try {
      String? userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          workoutReminders.value = data['workoutReminders'] ?? true;
          mealReminders.value = data['mealReminders'] ?? true;
          progressUpdates.value = data['progressUpdates'] ?? true;
          dataSharing.value = data['dataSharing'] ?? false;
          profileVisibility.value = data['profileVisibility'] ?? true;
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
  
  void toggleWorkoutReminders(bool value) async {
    workoutReminders.value = value;
    await _saveSettings();
    Get.snackbar(
      'Settings Updated',
      'Workout reminders ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void toggleMealReminders(bool value) async {
    mealReminders.value = value;
    await _saveSettings();
    Get.snackbar(
      'Settings Updated',
      'Meal reminders ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void toggleProgressUpdates(bool value) async {
    progressUpdates.value = value;
    await _saveSettings();
    Get.snackbar(
      'Settings Updated',
      'Progress updates ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void toggleDataSharing(bool value) async {
    dataSharing.value = value;
    await _saveSettings();
    Get.snackbar(
      'Settings Updated',
      'Data sharing ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  void toggleProfileVisibility(bool value) async {
    profileVisibility.value = value;
    await _saveSettings();
    Get.snackbar(
      'Settings Updated',
      'Profile visibility ${value ? 'enabled' : 'disabled'}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
  
  Future<void> _saveSettings() async {
    try {
      String? userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set({
          'workoutReminders': workoutReminders.value,
          'mealReminders': mealReminders.value,
          'progressUpdates': progressUpdates.value,
          'dataSharing': dataSharing.value,
          'profileVisibility': profileVisibility.value,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  void navigateToEditProfile() {
    Get.back(); // Close settings
    // Profile screen already has edit functionality
  }
  
  void changePassword() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Change Password'),
          ],
        ),
        content: const Text(
          'A password reset link will be sent to your email address. Click the link in the email to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                String? email = _firebaseService.currentUser?.email;
                if (email != null) {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Get.snackbar(
                    'Success',
                    'Password reset link sent to $email',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to send reset email: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
  
  void openHelpCenter() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.info),
            const SizedBox(width: 12),
            const Text('Help Center'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'How do I track my workouts?',
                'Go to the Exercise tab, select your workout plan, and start tracking your exercises in real-time.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I log my meals?',
                'Use the Meal Scan feature to scan your food or manually add meals in the Diet Plan section.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I view my progress?',
                'Navigate to the Progress Dashboard to see your workout stats, streaks, and achievements.',
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                'How do I change my fitness goals?',
                'Go to your Profile and update your fitness goals and personal information.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
  
  void contactSupport() {
    supportMessageController.clear();
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.support_agent, color: AppColors.success),
            const SizedBox(width: 12),
            const Text('Contact Support'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How can we help you?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: supportMessageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your issue or question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Email: support@mealmentor.com',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (supportMessageController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your message',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              try {
                String? userId = _firebaseService.currentUser?.uid;
                String? userEmail = _firebaseService.currentUser?.email;
                
                if (userId != null) {
                  await _firestore.collection('support_tickets').add({
                    'userId': userId,
                    'userEmail': userEmail,
                    'message': supportMessageController.text.trim(),
                    'status': 'open',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Your message has been sent. We\'ll get back to you soon!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to send message: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }
  
  void reportBug() {
    bugDescriptionController.clear();
    bugStepsController.clear();
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bug_report_outlined, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Report a Bug'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bug Description',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bugDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What happened?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps to Reproduce',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bugStepsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'How can we reproduce this bug?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (bugDescriptionController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please describe the bug',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              try {
                String? userId = _firebaseService.currentUser?.uid;
                String? userEmail = _firebaseService.currentUser?.email;
                
                if (userId != null) {
                  await _firestore.collection('bug_reports').add({
                    'userId': userId,
                    'userEmail': userEmail,
                    'description': bugDescriptionController.text.trim(),
                    'stepsToReproduce': bugStepsController.text.trim(),
                    'status': 'open',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Bug report submitted. Thank you for helping us improve!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to submit bug report: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
  
  void openTermsOfService() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.secondary),
            const SizedBox(width: 12),
            const Text('Terms of Service'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MealMentor AI - Terms of Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Acceptance of Terms',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'By accessing and using MealMentor AI, you accept and agree to be bound by the terms and provision of this agreement.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. Use License',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Permission is granted to temporarily use MealMentor AI for personal, non-commercial purposes.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. User Account',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are responsible for maintaining the confidentiality of your account and password.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Health Disclaimer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'MealMentor AI provides general fitness and nutrition information. Always consult with a healthcare professional before starting any fitness or diet program.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void openPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: AppColors.info),
            const SizedBox(width: 12),
            const Text('Privacy Policy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MealMentor AI - Privacy Policy',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Information We Collect',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'We collect information you provide directly to us, including your name, email, fitness goals, and workout data.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '2. How We Use Your Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'We use your information to provide personalized workout and meal plans, track your progress, and improve our services.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Data Security',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'We implement appropriate security measures to protect your personal information from unauthorized access.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '4. Data Sharing',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'We do not sell your personal information. We may share anonymized data for research purposes only if you have enabled data sharing in settings.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                '5. Your Rights',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have the right to access, update, or delete your personal information at any time through your profile settings.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  String getAppVersion() {
    return '1.0.0';
  }
}
