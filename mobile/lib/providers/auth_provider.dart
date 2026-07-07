import 'dart:convert';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends GetxController {
  final api = Get.find<ApiService>();
  final storage = Get.find<StorageService>();
  final socketService = Get.find<SocketService>();

  final user = Rx<UserModel?>(null);
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final error = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSavedUser();
  }

  void _loadSavedUser() {
    final token = storage.token;
    final userData = storage.userData;
    if (token != null && userData != null) {
      try {
        api.setToken(token);
        final userJson = jsonDecode(userData);
        user.value = UserModel.fromJson(userJson);
        isLoggedIn.value = true;
        socketService.connect(token);
      } catch (e) {
        logout();
      }
    }
  }

  Future<bool> sendOtp(String phone) async {
    try {
      isLoading.value = true;
      error.value = null;
      await api.post('auth/send-otp', body: {'phone': phone});
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp, {String? username}) async {
    try {
      isLoading.value = true;
      error.value = null;
      final response = await api.post('auth/verify-otp', body: {
        'phone': phone,
        'otp': otp,
        'username': username,
        'countryCode': '+964',
      });

      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;

      api.setToken(token);
      storage.token = token;
      storage.userData = jsonEncode(userJson);

      user.value = UserModel.fromJson(userJson);
      isLoggedIn.value = true;

      socketService.connect(token);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = null;
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyGoogleToken(String googleId, String email, String displayName, String photoURL) async {
    try {
      isLoading.value = true;
      final response = await api.post('auth/google', body: {
        'googleId': googleId,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
      });

      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;

      api.setToken(token);
      storage.token = token;
      storage.userData = jsonEncode(userJson);

      user.value = UserModel.fromJson(userJson);
      isLoggedIn.value = true;

      socketService.connect(token);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final response = await api.put('auth/profile', body: data);
      user.value = UserModel.fromJson(response);
      storage.userData = jsonEncode(response);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    socketService.disconnect();
    await storage.clear();
    api.setToken(null);
    user.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
