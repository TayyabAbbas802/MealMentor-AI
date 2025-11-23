import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit),
            onPressed: controller.toggleEdit,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentUser.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildBMICard(),
              const SizedBox(height: 24),
              _buildProfileForm(),
              const SizedBox(height: 24),
              if (controller.isEditing.value) ...[
                CustomButton(
                  text: 'Save Changes',
                  onPressed: controller.saveProfile,
                  isLoading: controller.isLoading.value,
                ),
                const SizedBox(height: 16),
              ],
              _buildSettingsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(
            Icons.person,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => Text(
          controller.currentUser.value?.name ?? 'User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        )),
        const SizedBox(height: 4),
        Obx(() => Text(
          controller.currentUser.value?.email ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        )),
      ],
    );
  }

  Widget _buildBMICard() {
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Body Mass Index (BMI)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      controller.bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'BMI',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getBMIColor(controller.bmi).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.bmiCategory,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getBMIColor(controller.bmi),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  Color _getBMIColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildProfileForm() {
    return Obx(() => Column(
      children: [
        CustomTextField(
          label: 'Full Name',
          controller: controller.nameController,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          controller: controller.emailController,
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Age',
          controller: controller.ageController,
          prefixIcon: const Icon(Icons.cake_outlined),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Weight (kg)',
          controller: controller.weightController,
          prefixIcon: const Icon(Icons.monitor_weight_outlined),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Height (cm)',
          controller: controller.heightController,
          prefixIcon: const Icon(Icons.height_outlined),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Goal',
          controller: controller.goalController,
          prefixIcon: const Icon(Icons.flag_outlined),
          hint: 'e.g., Lose weight, Gain muscle',
        ),
      ],
    ));
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Logout',
          onPressed: controller.logout,
          icon: Icons.logout,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: controller.deleteAccount,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Delete Account'),
        ),
      ],
    );
  }
}
