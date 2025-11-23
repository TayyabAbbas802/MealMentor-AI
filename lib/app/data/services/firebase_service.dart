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
        'goal': '',
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
}
