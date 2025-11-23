import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text Controllers - REMOVE dispose calls since GetX manages lifecycle
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable Variables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final acceptTerms = false.obs;
  final rememberMe = false.obs;

  // Current User
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // REMOVE onClose method entirely - Let GetX handle disposal
  // @override
  // void onClose() {
  //   nameController.dispose();
  //   emailController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.onClose();
  // }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  bool _validateSignupInputs() {
    if (nameController.text.trim().isEmpty) {
      _showErrorSnackbar('Name Required', 'Please enter your full name');
      return false;
    }
    if (nameController.text.trim().length < 3) {
      _showErrorSnackbar('Invalid Name', 'Name must be at least 3 characters');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Email Required', 'Please enter your email address');
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      _showErrorSnackbar('Invalid Email', 'Please enter a valid email address');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showErrorSnackbar('Password Required', 'Please create a password');
      return false;
    }
    if (passwordController.text.length < 8) {
      _showErrorSnackbar('Weak Password', 'Password must be at least 8 characters long');
      return false;
    }
    if (confirmPasswordController.text.isEmpty) {
      _showErrorSnackbar('Confirmation Required', 'Please confirm your password');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Password Mismatch', 'Passwords do not match. Please try again.');
      return false;
    }
    if (!acceptTerms.value) {
      _showErrorSnackbar('Terms Required', 'Please accept the Terms & Conditions to continue');
      return false;
    }
    return true;
  }

  Future<void> signup() async {
    if (!_validateSignupInputs()) return;

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final user = userCredential.user!;
        await user.updateDisplayName(nameController.text.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': emailController.text.trim().toLowerCase(),
          'profileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }

        Get.snackbar(
          '🎉 Success',
          'Account created! Complete your profile to get started.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        _clearControllers();
        Get.offAllNamed(AppRoutes.USER_INFO);
      }
    } on FirebaseAuthException catch (e) {
      String title = 'Sign Up Failed';
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          title = 'Email Already Exists';
          message = 'This email is already registered. Please login instead.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid. Please check and try again.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled. Contact support.';
          break;
        case 'weak-password':
          message = 'Your password is too weak. Please use a stronger password.';
          break;
        case 'network-request-failed':
          title = 'Network Error';
          message = 'Please check your internet connection and try again.';
          break;
        default:
          message = e.message ?? 'An unexpected error occurred. Please try again.';
      }
      _showErrorSnackbar(title, message);
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateLoginInputs() {
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar('Email Required', 'Please enter your email address');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showErrorSnackbar('Password Required', 'Please enter your password');
      return false;
    }
    return true;
  }

  Future<void> login() async {
    if (!_validateLoginInputs()) return;

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        bool profileComplete = userDoc.exists &&
            (userDoc.data() as Map<String, dynamic>?)?['profileComplete'] == true;

        Get.snackbar(
          '✅ Welcome Back',
          'Logged in successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        _clearControllers();

        if (profileComplete) {
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          Get.offAllNamed(AppRoutes.USER_INFO);
        }
      }
    } on FirebaseAuthException catch (e) {
      String title = 'Login Failed';
      String message;

      switch (e.code) {
        case 'user-not-found':
          title = 'Account Not Found';
          message = 'No account exists with this email. Please sign up.';
          break;
        case 'wrong-password':
          title = 'Incorrect Password';
          message = 'The password you entered is incorrect. Please try again.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        case 'user-disabled':
          title = 'Account Disabled';
          message = 'This account has been disabled. Contact support.';
          break;
        case 'too-many-requests':
          title = 'Too Many Attempts';
          message = 'Too many failed login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          title = 'Network Error';
          message = 'Please check your internet connection.';
          break;
        case 'invalid-credential':
          title = 'Invalid Credentials';
          message = 'Email or password is incorrect. Please try again.';
          break;
        default:
          message = e.message ?? 'An error occurred. Please try again.';
      }
      _showErrorSnackbar(title, message);
    } catch (e) {
      _showErrorSnackbar('Error', 'An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _clearControllers();
      Get.offAllNamed(AppRoutes.LOGIN);

      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _showErrorSnackbar('Email Required', 'Please enter your email address');
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());

      Get.snackbar(
        'Email Sent',
        'Password reset link has been sent to your email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Failed to send reset email';
      }
      _showErrorSnackbar('Reset Failed', message);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLogin() {
    _clearControllers();
    Get.offNamed(AppRoutes.LOGIN);
  }

  void navigateToSignup() {
    _clearControllers();
    Get.offNamed(AppRoutes.SIGNUP);
  }

  void _clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    obscurePassword.value = true;
    acceptTerms.value = false;
    rememberMe.value = false;
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
}