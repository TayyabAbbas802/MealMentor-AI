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
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: controller.navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentUser.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.currentUser.value;
        final isEditing = controller.isEditing.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // User Information Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BMI Card (always visible)
                    if (!isEditing) ...[
                      _buildBMICard(),
                      const SizedBox(height: 16),
                    ],

                    // Personal Information Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (!isEditing)
                          TextButton.icon(
                            onPressed: controller.toggleEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Editable or Display Mode
                    if (isEditing) ...[
                      // Edit Mode - Show Text Fields
                      _buildEditableField(
                        label: 'Full Name',
                        controller: controller.nameController,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Age',
                        controller: controller.ageController,
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Gender',
                        controller: controller.genderController,
                        icon: Icons.wc_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Weight (kg)',
                        controller: controller.weightController,
                        icon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        label: 'Height (cm)',
                        controller: controller.heightController,
                        icon: Icons.height_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      // Fitness Goal Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, color: AppColors.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: controller.goalController.text.isEmpty 
                                    ? null 
                                    : controller.goalController.text,
                                decoration: const InputDecoration(
                                  labelText: 'Fitness Goal',
                                  border: InputBorder.none,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Lose Weight',
                                    child: Text('Lose Weight'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Gain Muscle',
                                    child: Text('Gain Muscle'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Maintain Weight',
                                    child: Text('Maintain Weight'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.goalController.text = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save and Cancel Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.toggleEdit,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: AppColors.textSecondary),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: controller.saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Display Mode - Show Info Cards
                      _buildInfoCard(
                        icon: Icons.cake_outlined,
                        label: 'Age',
                        value: '${user?.age ?? 0} years',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.wc_outlined,
                        label: 'Gender',
                        value: user?.gender ?? 'Not specified',
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Weight',
                        value: '${user?.weight.toStringAsFixed(1) ?? 0} kg',
                        color: AppColors.info,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.height_outlined,
                        label: 'Height',
                        value: '${user?.height.toStringAsFixed(1) ?? 0} cm',
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.flag_outlined,
                        label: 'Fitness Goal',
                        value: user?.goal ?? 'Not set',
                        color: AppColors.success,
                      ),
                    ],
                    
                    const SizedBox(height: 24),

                    // Action Buttons (only in display mode)
                    if (!isEditing) ...[
                      CustomButton(
                        text: 'Settings',
                        onPressed: controller.navigateToSettings,
                        icon: Icons.settings,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Logout',
                        onPressed: controller.logout,
                        icon: Icons.logout,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.deleteAccount,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getBMIColor(controller.bmi).withOpacity(0.1),
            _getBMIColor(controller.bmi).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBMIColor(controller.bmi).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBMIColor(controller.bmi).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              size: 40,
              color: _getBMIColor(controller.bmi),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Body Mass Index',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getBMIColor(controller.bmi),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getBMIColor(controller.bmi),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          controller.bmiCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi == 0) return Colors.grey;
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
