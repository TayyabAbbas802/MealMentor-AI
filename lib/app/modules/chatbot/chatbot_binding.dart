import 'package:get/get.dart';
import 'package:meal_mentor_ai/app/data/services/firebase_service.dart';
import 'chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
