import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../routes/app_routes.dart';
import '../../data/services/firebase_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In (for version 6.x)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final acceptTerms = false.obs;
  final rememberMe = false.obs;

  // Current User
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    super.onInit();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Remember me toggle
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  // VALIDATION: Signup
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
      _showErrorSnackbar('Email Required', 'Please enter your email');
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      _showErrorSnackbar('Invalid Email', 'Enter a valid email address');
      return false;
    }
    if (passwordController.text.length < 8) {
      _showErrorSnackbar('Weak Password', 'Password must be at least 8 characters');
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Password Mismatch', 'Passwords do not match');
      return false;
    }
    if (!acceptTerms.value) {
      _showErrorSnackbar('Terms Required', 'Please accept Terms & Conditions');
      return false;
    }
    return true;
  }

  // SIGN UP
  Future<void> signup() async {
    if (!_validateSignupInputs()) return;

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user!;
      await user.updateDisplayName(nameController.text.trim());

      // Use FirebaseService to create user document consistently
      final firebaseService = Get.find<FirebaseService>();
      await firebaseService.createUserDocument(
        userId: user.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      Get.offAllNamed(AppRoutes.USER_INFO);

    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Signup Failed", e.message ?? "Error");
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _showErrorSnackbar("Email Required", "Please enter your email");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        "Success",
        "Password reset link sent to your email",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar("Error", e.toString());
    }
  }
  void navigateToSignup() {
    Get.toNamed(AppRoutes.SIGNUP);
  }
  void navigateToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }

  // LOGIN
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _showErrorSnackbar("Error", "Email & password required");
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _handleSocialSignIn(userCredential, isLogin: true);

    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar("Login Failed", e.message ?? "Error");
    } finally {
      isLoading.value = false;
    }
  }

  // GOOGLE SIGN IN (Correct for version 6.x)
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _auth.signInWithCredential(credential);

      await _handleSocialSignIn(userCredential);

    } catch (e) {
      _showErrorSnackbar("Google Sign-In Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // FACEBOOK SIGN IN
  Future<void> signInWithFacebook() async {
    try {
      print("Starting Facebook login...");

      // Trigger Facebook login with public_profile only
      // Note: 'email' permission requires Facebook App Review approval
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      print("Facebook login result status: ${result.status}");

      // Check login status
      switch (result.status) {
        case LoginStatus.success:
          print("Facebook login successful");
          final AccessToken? accessToken = result.accessToken;

          if (accessToken == null) {
            Get.snackbar("Error", "Facebook access token is null");
            return;
          }

          print("Access token received: ${accessToken.token.substring(0, 20)}...");

          // Create Firebase credential
          final OAuthCredential facebookCredential =
              FacebookAuthProvider.credential(accessToken.token);

          // Sign in with Firebase
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(facebookCredential);

          print("Firebase sign-in successful: ${userCredential.user?.uid}");
          
          // Use the existing _handleSocialSignIn method for consistency
          await _handleSocialSignIn(userCredential);
          break;

        case LoginStatus.cancelled:
          print("Facebook login cancelled by user");
          Get.snackbar("Cancelled", "Facebook login cancelled by user");
          break;

        case LoginStatus.failed:
          print("Facebook login failed: ${result.message}");
          Get.snackbar("Error", result.message ?? "Facebook login failed");
          break;

        case LoginStatus.operationInProgress:
          print("Facebook login operation already in progress");
          // Don't show error, just ignore duplicate calls
          break;

        default:
          print("Unknown Facebook login status: ${result.status}");
          Get.snackbar("Error", "Unknown login error: ${result.status}");
      }
    } catch (e, stacktrace) {
      print("Exception during Facebook login: $e");
      print(stacktrace);
      
      // More specific error messages
      if (e.toString().contains('invalid-credential') || 
          e.toString().contains('Malformed access token')) {
        Get.snackbar(
          "Facebook Login Error",
          "Facebook authentication failed. Please try again or use a different login method.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar("Error", "Failed to login with Facebook");
      }
    }
  }


  // Handle new + returning users
  Future<void> _handleSocialSignIn(UserCredential userCredential,
      {bool isLogin = false}) async {
    final user = userCredential.user!;
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.offAllNamed(AppRoutes.USER_INFO);
      return;
    }

    final data = doc.data()!;
    bool profileComplete = data['profileComplete'] ?? false;

    if (profileComplete) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.offAllNamed(AppRoutes.USER_INFO);
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;
}
