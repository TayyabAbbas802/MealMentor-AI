import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealMentor AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Let's track your nutrition today",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildQuickStats(),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 32),
            const Text(
              'Recent Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentMeals(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToMealScan,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Meal'),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Obx(() => DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.textLight,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.userName,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.userEmail,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Diet Plan'),
            onTap: controller.navigateToDietPlan,
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Exercise'),
            onTap: controller.navigateToExercise,
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Nutrition Stats'),
            onTap: controller.navigateToNutrition,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: controller.navigateToProfile,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Get.back();
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Calories', '1,450', '/ 2,000', Icons.local_fire_department),
                _buildStatItem('Protein', '65g', '/ 150g', Icons.egg),
                _buildStatItem('Water', '6', '/ 8 cups', Icons.water_drop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String target, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          target,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          'Scan Meal',
          Icons.camera_alt,
          AppColors.primary,
          controller.navigateToMealScan,
        ),
        _buildActionCard(
          'Diet Plan',
          Icons.restaurant_menu,
          AppColors.secondary,
          controller.navigateToDietPlan,
        ),
        _buildActionCard(
          'Exercise',
          Icons.fitness_center,
          const Color(0xFF9C27B0),
          controller.navigateToExercise,
        ),
        _buildActionCard(
          'Nutrition',
          Icons.bar_chart,
          const Color(0xFF2196F3),
          controller.navigateToNutrition,
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMeals() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, color: AppColors.primary),
            ),
            title: Text('Meal ${index + 1}'),
            subtitle: const Text('450 cal • 2 hours ago'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}
