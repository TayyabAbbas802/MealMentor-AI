import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:meal_mentor_ai/app/data/models/user_model.dart';
import 'package:meal_mentor_ai/app/data/services/firebase_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotController extends GetxController {
  final _firebaseService = Get.find<FirebaseService>();
  final textController = TextEditingController();
  final messages = <String>[].obs;
  final isLoading = false.obs;
  final _conversationHistory = <Content>[].obs;

  UserModel? user;
  GenerativeModel? _model;
  bool _isModelInitialized = false;
  @override
  void onInit() async {
    super.onInit();
    _initializeGenerativeModel();
    _loadUserData();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> _initializeGenerativeModel() async {
    String apiKey = '';

    // Priority 1: Build-time environment variable
    apiKey = const String.fromEnvironment('GEMINI_API_KEY');

    // Priority 2: .env file (only if not found in build-time)
    if (apiKey.isEmpty) {
      try {
        // Load .env file from assets
        await dotenv.load(fileName: '.env');
        apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
      } catch (e) {
        print('Note: .env file not found or error loading: $e');
      }
    }

    // If still empty, show error
    if (apiKey.isEmpty) {
      print('⚠️ GEMINI_API_KEY not found. Please either:');
      print('   1. Add to .env file in project root and add to pubspec.yaml assets');
      print('   2. Run with: flutter run --dart-define=GEMINI_API_KEY=your_key');
      messages.add('AI: Chatbot is not configured. Please setup API key.');
      return;
    }

    try {
      const modelName = 'gemini-2.5-flash';
      final generationConfig = GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 800,
      );

      final safetySettings = [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ];

      _model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: generationConfig,
        safetySettings: safetySettings,
      );
      _isModelInitialized = true;
      print('Successfully initialized $modelName model.');
    } catch (e) {
      print('Error initializing generative model: $e');
      messages.add('AI: Could not initialize MealMentor. Please check your API key and network.');
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      user = await _firebaseService.getUserDocument(currentUser.uid);
      final userName = user?.name ?? 'there';

      // Initialize conversation history with system prompt
      final systemPrompt = Content.text('''
You are MealMentor AI, a professional nutritionist and diet planner specializing in Asian foods, particularly Pakistani and Indian cuisine.

CRITICAL INSTRUCTIONS:
1. Be concise and to the point - responses should be under 150 words unless detailed meal planning is requested
2. NEVER hallucinate or make up information
3. Only provide verified nutritional information
4. Use bullet points or short paragraphs for readability
5. If you don't know something, say so clearly
6. Focus on practical, actionable advice
7. Format responses neatly with clear sections
8. Always consider cultural food preferences when suggesting meals

Current user context will be provided separately.
''');
      _conversationHistory.add(systemPrompt);

      // Add user introduction
      final introduction = Content.text('''
Introduce yourself as MealMentor AI and explain you can help with personalized diet plans based on:
- Name: ${user?.name ?? 'User'}
- Age: ${user?.age ?? 'Not specified'} years
- Height: ${user?.height ?? 'Not specified'} cm
- Weight: ${user?.weight ?? 'Not specified'} kg
- Goal: ${user?.goal ?? 'Not specified'}
Keep introduction under 50 words and friendly.
''');
      _conversationHistory.add(introduction);

      // Get AI's introduction
      try {
        if (_model != null) {
          final response = await _model!.generateContent(_conversationHistory);
          messages.add(response.text ?? 'Hello $userName! I\'m MealMentor AI, your personal nutrition guide.');
        } else {
          messages.add('Hello $userName! I\'m MealMentor AI, ready to help with your personalized diet plan.');
        }
      } catch (e) {
        messages.add('Hello $userName! I\'m MealMentor AI, ready to help with your personalized diet plan.');
      }
    } else {
      messages.add('Hello! I\'m MealMentor AI. Please log in for personalized diet advice.');
    }
  }

  Future<void> sendMessage() async {
    final message = textController.text.trim();
    if (message.isEmpty) return;

    messages.add('You: $message');
    textController.clear();

    if (!_isModelInitialized || _model == null) {
      messages.add('AI: MealMentor is not initialized. Please check the configuration.');
      return;
    }

    isLoading.value = true;

    try {
      // Add user message to conversation history
      final userContent = Content.text(message);
      _conversationHistory.add(userContent);

      // Create focused prompt based on message type
      final focusedPrompt = _createFocusedPrompt(message);
      final promptContent = Content.text(focusedPrompt);

      // Use conversation history for context
      final responseContent = await _model!.generateContent(
        [..._conversationHistory, promptContent],
      );

      final aiResponse = responseContent.text ?? 'I apologize, I couldn\'t process that request.';

      // Add AI response to conversation history (limited to last 10 messages to prevent token overflow)
      _conversationHistory.add(Content.text(aiResponse));
      if (_conversationHistory.length > 20) { // Keep system prompt + 10 exchanges
        _conversationHistory.removeRange(1, 3); // Remove oldest user+AI pair
      }

      messages.add(aiResponse);
    } catch (e) {
      print('Error generating response: $e');
      messages.add('AI: Sorry, I encountered an issue. Please try again with a more specific question.');
    } finally {
      isLoading.value = false;
    }
  }

  String _createFocusedPrompt(String userMessage) {
    String basePrompt = '''
User asked: "$userMessage"

IMPORTANT: 
- Be concise (under 150 words unless detailed meal plan requested)
- No hallucinations - only provide verified information
- Use clear formatting (bullet points, short paragraphs)
- Focus on Asian/Pakistani/Indian foods when relevant
- If unsure, say "I don't have verified information on that"

''';

    if (user != null) {
      // Using only the properties available in your UserModel
      basePrompt += '''
User context for personalized advice:
- Name: ${user!.name}
- Age: ${user!.age} years
- Height: ${user!.height} cm
- Weight: ${user!.weight} kg
- Goal: ${user!.goal}

Based on the above, calculate BMI if relevant and provide a concise, accurate response focusing on practical advice.
For dietary suggestions, assume standard dietary preferences unless the user specifies otherwise.
''';
    } else {
      basePrompt += '''
Note: User not logged in. Provide general advice only.
''';
    }

    // Add specific instructions based on query type
    if (userMessage.toLowerCase().contains('meal plan') ||
        userMessage.toLowerCase().contains('diet plan') ||
        userMessage.toLowerCase().contains('schedule')) {
      basePrompt += '''
If providing a meal plan:
1. Include specific dishes (e.g., "Chapati with daal" not just "carbohydrates")
2. Mention portion sizes
3. Suggest meal timings
4. Keep it culturally appropriate
5. Format as: Meal Time - Dish (Portion)
6. Consider user's age and goal when planning
''';
    }

    if (userMessage.toLowerCase().contains('recipe') ||
        userMessage.toLowerCase().contains('how to cook') ||
        userMessage.toLowerCase().contains('make')) {
      basePrompt += '''
If providing recipes:
1. List ingredients with measurements
2. Provide step-by-step instructions
3. Mention cooking time
4. Include serving size
5. Keep it simple and clear
6. Suggest healthy alternatives if applicable
''';
    }

    if (userMessage.toLowerCase().contains('calori') ||
        userMessage.toLowerCase().contains('nutrit') ||
        userMessage.toLowerCase().contains('protein') ||
        userMessage.toLowerCase().contains('vitamin')) {
      basePrompt += '''
If providing nutritional information:
1. Use verified data only
2. Cite approximate values
3. Compare with common foods
4. Mention daily requirements if relevant
5. Be specific about serving sizes
6. Consider user's age and goal
''';
    }

    if (userMessage.toLowerCase().contains('bmi') ||
        userMessage.toLowerCase().contains('weight') ||
        userMessage.toLowerCase().contains('lose') ||
        userMessage.toLowerCase().contains('gain')) {
      basePrompt += '''
If discussing weight/BMI:
1. Calculate BMI: weight(kg) / (height(m) * height(m))
2. Provide healthy weight range
3. Suggest safe rate of weight change (0.5-1kg per week)
4. Focus on sustainable habits
5. Emphasize nutrition over extreme diets
''';
    }

    return basePrompt;
  }

  // Clear chat history
  void clearChat() {
    messages.clear();
    _conversationHistory.clear();
    _loadUserData(); // Reload with fresh introduction
  }

  // Quick response templates for common questions
  void sendQuickQuestion(String question) {
    textController.text = question;
    sendMessage();
  }
}