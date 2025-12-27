import 'package:get/get.dart';
import 'package:meal_mentor_ai/app/data/models/user_info/user_info_binding.dart';
import 'package:meal_mentor_ai/app/data/models/user_info/user_info_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/signup_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/meal_scan/meal_scan_binding.dart';
import '../modules/meal_scan/meal_scan_view.dart';
import '../modules/nutrition/nutrition_binding.dart';
import '../modules/nutrition/progress_view.dart';
import '../modules/diet_plan/diet_plan_binding.dart';
import '../modules/diet_plan/diet_plan_view.dart';
import '../modules/chatbot/chatbot_binding.dart';
import '../modules/chatbot/chatbot_view.dart';
import '../modules/exercise/exercise_binding.dart';
import '../modules/exercise/exercise_view.dart' as exercise;  // ✅ FIX: Add alias to avoid conflict
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/Tutorial/tutorial_binding.dart';
import '../modules/Tutorial/tutorial_view.dart';

// ✅ Workout system imports
import '../modules/workout_plan/exercise_setup_screen.dart' as workout;  // ✅ FIX: Add alias
import '../modules/workout_plan/weekly_plan_screen.dart';
import '../modules/workout_plan/workout_plan_binding.dart';
import '../modules/active_workout_progress/active_workout_screen.dart';
import '../modules/active_workout_progress/active_workout_binding.dart';
import '../modules/progress/progress_dashboard.dart';
import '../modules/progress/progress_binding.dart';
import '../data/models/workout_plan_model.dart';
import '../data/services/firebase_service.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.SPLASH;

  static final pages = [
    // Splash Screen
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Onboarding Screen
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.TUTORIAL,
      page: () => const TutorialView(),
      binding: TutorialBinding(),
    ),

    // Auth Screens
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // User Info Collection Screen
    GetPage(
      name: AppRoutes.USER_INFO,
      page: () => const UserInfoView(),
      binding: UserInfoBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Main App Screens
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.MEAL_SCAN,
      page: () => const MealScanView(),
      binding: MealScanBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.NUTRITION,
      page: () => const ProgressView(),
      binding: NutritionBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.DIET_PLAN,
      page: () => const DietPlanView(),
      binding: DietPlanBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.CHATBOT,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.EXERCISE,
      page: () => const exercise.ExerciseView(),  // ✅ FIX: Use alias
      binding: ExerciseBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ✅ Workout System Pages
    GetPage(
      name: AppRoutes.EXERCISE_SETUP,
      page: () => const workout.ExerciseSetupScreen(),  // ✅ FIX: Use alias
      binding: WorkoutPlanBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.WEEKLY_PLAN,
      page: () => const WeeklyPlanScreen(),
      binding: WorkoutPlanBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.ACTIVE_WORKOUT,
      page: () => const ActiveWorkoutScreen(),  // ✅ Just create screen without params
      binding: ActiveWorkoutBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: AppRoutes.PROGRESS_DASHBOARD,
      page: () => ProgressDashboard(
        userId: Get.arguments['userId'] as String,  // ✅ FIX: Direct access
        planId: Get.arguments['planId'] as String,
      ),
      binding: ProgressBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
