import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class FirebaseService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _auth.currentUser != null;

  // ============ AUTHENTICATION METHODS ============

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('Starting signup process...'); // Debug

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created in Auth: ${userCredential.user?.uid}'); // Debug

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      print('Display name updated'); // Debug

      // Create user document in Firestore
      await createUserDocument(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
      );

      print('User document created in Firestore'); // Debug

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // Debug
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during signup: $e'); // Debug
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting login process...'); // Debug

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Login successful: ${userCredential.user?.uid}'); // Debug
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // Debug
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error during login: $e'); // Debug
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      print('Creating user document for: $userId'); // Debug

      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'age': 0,
        'weight': 0.0,
        'height': 0.0,
        'goal': 'maintenance', // Default goal for exercise system
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('User document created successfully'); // Debug
    } catch (e) {
      print('Error creating user document: $e'); // Debug
      throw 'Failed to create user profile: ${e.toString()}';
    }
  }

  // Get user document from Firestore
  Future<UserModel?> getUserDocument(String userId) async {
    try {
      print('Fetching user document for: $userId'); // Debug

      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('User document data: $data'); // Debug
        return UserModel.fromJson(data);
      }

      print('User document does not exist'); // Debug
      return null;
    } catch (e) {
      print('Error fetching user document: $e'); // Debug
      print('Error type: ${e.runtimeType}'); // Debug
      // Don't throw error, just return null
      return null;
    }
  }

  // Update user document
  Future<void> updateUserDocument({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user document: $e'); // Debug
      throw 'Failed to update user profile: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e'); // Debug
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      String userId = _auth.currentUser!.uid;

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user from Firebase Auth
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting account: $e'); // Debug
      throw 'Failed to delete account: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('Error resetting password: $e'); // Debug
      throw 'Failed to send password reset email: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    print('Auth exception code: ${e.code}'); // Debug
    print('Auth exception message: ${e.message}'); // Debug

    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }

  // ============ NUTRITION METHODS ============

  // Save meal to Firestore
  Future<void> saveMeal({
    required String userId,
    required Map<String, dynamic> mealData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .add({
        ...mealData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving meal: $e'); // Debug
      throw 'Failed to save meal: ${e.toString()}';
    }
  }

  // Get user meals
  Stream<QuerySnapshot> getUserMeals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Save nutrition log
  Future<void> saveNutritionLog({
    required String userId,
    required Map<String, dynamic> nutritionData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('nutrition_logs')
          .add({
        ...nutritionData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving nutrition log: $e'); // Debug
      throw 'Failed to save nutrition log: ${e.toString()}';
    }
  }

  // Get nutrition logs
  Stream<QuerySnapshot> getNutritionLogs(String userId, {DateTime? date}) {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('nutrition_logs');

    if (date != null) {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // ============ EXERCISE SYSTEM METHODS ============

  /// Create a new workout plan
  Future<String> createWorkoutPlan({
    required String userId,
    required String name,
    required String difficulty,
    required int daysPerWeek,
    required String goal,
    required List<Map<String, dynamic>> daysSchedule,
  }) async {
    try {
      print('Creating workout plan for user: $userId'); // Debug

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .add({
        'name': name,
        'difficulty': difficulty,
        'daysPerWeek': daysPerWeek,
        'goal': goal,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'daysSchedule': daysSchedule,
      });

      print('Workout plan created with ID: ${docRef.id}'); // Debug
      return docRef.id;
    } catch (e) {
      print('Error creating workout plan: $e'); // Debug
      throw 'Failed to create workout plan: ${e.toString()}';
    }
  }

  /// Get all workout plans for user
  Future<List<Map<String, dynamic>>> getWorkoutPlans(String userId) async {
    try {
      print('Fetching workout plans for user: $userId'); // Debug

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .orderBy('createdAt', descending: true)
          .get();

      final plans = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList();

      print('Retrieved ${plans.length} workout plans'); // Debug
      return plans;
    } catch (e) {
      print('Error getting workout plans: $e'); // Debug
      throw 'Failed to get workout plans: ${e.toString()}';
    }
  }

  /// Get specific workout plan
  Future<Map<String, dynamic>?> getWorkoutPlan(
      String userId,
      String planId,
      ) async {
    try {
      print('Fetching workout plan: $planId'); // Debug

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .doc(planId)
          .get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('Error getting workout plan: $e'); // Debug
      throw 'Failed to get workout plan: ${e.toString()}';
    }
  }

  /// Update workout plan
  Future<void> updateWorkoutPlan({
    required String userId,
    required String planId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .doc(planId)
          .update(updateData);

      print('Workout plan updated: $planId'); // Debug
    } catch (e) {
      print('Error updating workout plan: $e'); // Debug
      throw 'Failed to update workout plan: ${e.toString()}';
    }
  }

  /// Delete workout plan
  Future<void> deleteWorkoutPlan(String userId, String planId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutPlans')
          .doc(planId)
          .delete();

      print('Workout plan deleted: $planId'); // Debug
    } catch (e) {
      print('Error deleting workout plan: $e'); // Debug
      throw 'Failed to delete workout plan: ${e.toString()}';
    }
  }

  /// Log a completed workout
  Future<String> logWorkout({
    required String userId,
    required String planId,
    required int dayIndex,
    required List<Map<String, dynamic>> exerciseLogs,
    required int durationMinutes,
  }) async {
    try {
      print('Logging workout for user: $userId'); // Debug

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutLogs')
          .add({
        'planId': planId,
        'date': FieldValue.serverTimestamp(),
        'dayIndex': dayIndex,
        'exerciseLogs': exerciseLogs,
        'durationMinutes': durationMinutes,
        'isCompleted': true,
      });

      print('Workout logged with ID: ${docRef.id}'); // Debug
      return docRef.id;
    } catch (e) {
      print('Error logging workout: $e'); // Debug
      throw 'Failed to log workout: ${e.toString()}';
    }
  }

  /// Get workout logs for a specific plan
  Future<List<Map<String, dynamic>>> getWorkoutLogs(
      String userId,
      String planId,
      ) async {
    try {
      print('Fetching workout logs for plan: $planId'); // Debug

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutLogs')
          .where('planId', isEqualTo: planId)
          .orderBy('date', descending: true)
          .get();

      final logs = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList();

      print('Retrieved ${logs.length} workout logs'); // Debug
      return logs;
    } catch (e) {
      print('Error getting workout logs: $e'); // Debug
      throw 'Failed to get workout logs: ${e.toString()}';
    }
  }

  /// Get logs between date range
  Future<List<Map<String, dynamic>>> getWorkoutLogsDateRange({
    required String userId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('Fetching workout logs from $startDate to $endDate'); // Debug

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workoutLogs')
          .where('planId', isEqualTo: planId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      final logs = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList();

      return logs;
    } catch (e) {
      print('Error getting workout logs: $e'); // Debug
      throw 'Failed to get workout logs: ${e.toString()}';
    }
  }

  /// Stream workout logs (real-time updates)
  Stream<List<Map<String, dynamic>>> streamWorkoutLogs(
      String userId,
      String planId,
      ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workoutLogs')
        .where('planId', isEqualTo: planId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      'id': doc.id,
      ...doc.data(),
    })
        .toList());
  }

  /// Log progress metric
  Future<void> logProgressMetric({
    required String userId,
    required int exerciseWgerId,
    required String exerciseName,
    required double weight,
    required int reps,
    required int sets,
  }) async {
    try {
      final totalVolume = weight * reps * sets;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progressMetrics')
          .add({
        'date': FieldValue.serverTimestamp(),
        'exerciseWgerId': exerciseWgerId,
        'exerciseName': exerciseName,
        'weight': weight,
        'reps': reps,
        'sets': sets,
        'totalVolume': totalVolume,
      });

      print('Progress metric logged for: $exerciseName'); // Debug
    } catch (e) {
      print('Error logging progress metric: $e'); // Debug
      throw 'Failed to log progress metric: ${e.toString()}';
    }
  }

  /// Get progress metrics for an exercise
  Future<List<Map<String, dynamic>>> getExerciseProgress(
      String userId,
      int exerciseWgerId,
      ) async {
    try {
      print('Fetching progress for exercise: $exerciseWgerId'); // Debug

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progressMetrics')
          .where('exerciseWgerId', isEqualTo: exerciseWgerId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList();
    } catch (e) {
      print('Error getting exercise progress: $e'); // Debug
      throw 'Failed to get exercise progress: ${e.toString()}';
    }
  }

  /// Get all progress metrics
  Future<List<Map<String, dynamic>>> getAllProgressMetrics(String userId) async {
    try {
      print('Fetching all progress metrics'); // Debug

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progressMetrics')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data(),
      })
          .toList();
    } catch (e) {
      print('Error getting progress metrics: $e'); // Debug
      throw 'Failed to get progress metrics: ${e.toString()}';
    }
  }

  /// Calculate workout streak
  Future<int> getWorkoutStreak(String userId, String planId) async {
    try {
      final logs = await getWorkoutLogs(userId, planId);

      if (logs.isEmpty) return 0;

      int streak = 0;
      DateTime today = DateTime.now();

      for (int i = 0; i < logs.length; i++) {
        final logDate = (logs[i]['date'] as Timestamp).toDate();
        final expectedDate = today.subtract(Duration(days: i));

        // Check if log is within expected date (allowing for same day)
        if (logDate.year == expectedDate.year &&
            logDate.month == expectedDate.month &&
            logDate.day == expectedDate.day) {
          streak++;
        } else {
          break;
        }
      }

      print('Current workout streak: $streak days'); // Debug
      return streak;
    } catch (e) {
      print('Error calculating streak: $e'); // Debug
      return 0;
    }
  }

  /// Get calendar data for heatmap
  Future<Map<DateTime, int>> getCalendarData(
      String userId,
      String planId,
      ) async {
    try {
      final logs = await getWorkoutLogs(userId, planId);
      final calendarData = <DateTime, int>{};

      for (var log in logs) {
        final logDate = (log['date'] as Timestamp).toDate();
        final dateKey = DateTime(logDate.year, logDate.month, logDate.day);

        calendarData[dateKey] = (calendarData[dateKey] ?? 0) + 1;
      }

      return calendarData;
    } catch (e) {
      print('Error getting calendar data: $e');
      return {};
    }
  }

  // ============ CHAT CONVERSATION METHODS ============

  /// Create a new chat conversation
  Future<String> createChatConversation({
    required String userId,
    required String title,
  }) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .add({
        'userId': userId,
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': 0,
      });

      print('Chat conversation created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating chat conversation: $e');
      throw 'Failed to create chat conversation: ${e.toString()}';
    }
  }

  /// Get all chat conversations for a user
  Future<List<Map<String, dynamic>>> getChatConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting chat conversations: $e');
      return [];
    }
  }

  /// Stream chat conversations (real-time updates)
  Stream<List<Map<String, dynamic>>> streamChatConversations(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chatConversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Update conversation title
  Future<void> updateConversationTitle({
    required String userId,
    required String conversationId,
    required String title,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .update({
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating conversation title: $e');
      throw 'Failed to update conversation title: ${e.toString()}';
    }
  }

  /// Delete a chat conversation and all its messages
  Future<void> deleteChatConversation({
    required String userId,
    required String conversationId,
  }) async {
    try {
      // Delete all messages in the conversation
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the conversation
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .delete();

      print('Chat conversation deleted: $conversationId');
    } catch (e) {
      print('Error deleting chat conversation: $e');
      throw 'Failed to delete chat conversation: ${e.toString()}';
    }
  }

  /// Save a message to a conversation
  Future<String> saveChatMessage({
    required String userId,
    required String conversationId,
    required String content,
    required bool isUser,
  }) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'conversationId': conversationId,
        'content': content,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update conversation's updatedAt and messageCount
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .update({
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      print('Error saving chat message: $e');
      throw 'Failed to save chat message: ${e.toString()}';
    }
  }

  /// Get all messages for a conversation
  Future<List<Map<String, dynamic>>> getChatMessages({
    required String userId,
    required String conversationId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chatConversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  /// Stream messages for a conversation (real-time updates)
  Stream<List<Map<String, dynamic>>> streamChatMessages({
    required String userId,
    required String conversationId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chatConversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }
}
