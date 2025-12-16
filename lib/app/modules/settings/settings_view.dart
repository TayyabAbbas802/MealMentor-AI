import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account'),
            const SizedBox(height: 8),
            _buildAccountSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 8),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Privacy'),
            const SizedBox(height: 8),
            _buildPrivacySection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Support'),
            const SizedBox(height: 8),
            _buildSupportSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('About'),
            const SizedBox(height: 8),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your personal information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.navigateToEditProfile,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: AppColors.secondary,
              ),
            ),
            title: const Text('Change Password'),
            subtitle: const Text('Update your password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Obx(() => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Workout Reminders'),
            subtitle: const Text('Get notified about your workouts'),
            value: controller.workoutReminders.value,
            activeColor: AppColors.primary,
            onChanged: controller.toggleWorkoutReminders,
          )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.warning,
              ),
            ),
            title: const Text('Meal Reminders'),
            subtitle: const Text('Get notified about your meals'),
            value: controller.mealReminders.value,
            activeColor: AppColors.primary,
            onChanged: controller.toggleMealReminders,
          )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.trending_up,
                color: AppColors.info,
              ),
            ),
            title: const Text('Progress Updates'),
            subtitle: const Text('Get notified about your progress'),
            value: controller.progressUpdates.value,
            activeColor: AppColors.primary,
            onChanged: controller.toggleProgressUpdates,
          )),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Obx(() => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.secondary,
              ),
            ),
            title: const Text('Data Sharing'),
            subtitle: const Text('Share anonymous usage data'),
            value: controller.dataSharing.value,
            activeColor: AppColors.primary,
            onChanged: controller.toggleDataSharing,
          )),
          const Divider(height: 1),
          Obx(() => SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Profile Visibility'),
            subtitle: const Text('Make your profile visible to others'),
            value: controller.profileVisibility.value,
            activeColor: AppColors.primary,
            onChanged: controller.toggleProfileVisibility,
          )),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_outline,
                color: AppColors.info,
              ),
            ),
            title: const Text('Help Center'),
            subtitle: const Text('Browse FAQs and guides'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.openHelpCenter,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent,
                color: AppColors.success,
              ),
            ),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help from our team'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.contactSupport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bug_report_outlined,
                color: AppColors.error,
              ),
            ),
            title: const Text('Report a Bug'),
            subtitle: const Text('Help us improve the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.reportBug,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
            ),
            title: const Text('App Version'),
            subtitle: Text(controller.getAppVersion()),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.secondary,
              ),
            ),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.openTermsOfService,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.info,
              ),
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.openPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}
