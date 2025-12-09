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
import '../modules/nutrition/nutrition_view.dart';
import '../modules/diet_plan/diet_plan_binding.dart';
import '../modules/diet_plan/diet_plan_view.dart';
import '../modules/chatbot/chatbot_binding.dart';
import '../modules/chatbot/chatbot_view.dart';
import '../modules/exercise/exercise_binding.dart';
import '../modules/exercise/exercise_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/Tutorial/tutorial_binding.dart';
import '../modules/Tutorial/tutorial_view.dart';
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
      page: () => const NutritionView(),
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
      page: () => const ExerciseView(),
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
  ];
}
