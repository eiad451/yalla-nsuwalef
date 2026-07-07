import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/phone_auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/rooms/room_screen.dart';
import 'screens/rooms/voice_room_screen.dart';
import 'screens/rooms/create_room_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/wallet/recharge_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/room_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/wallet_provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Get.put(StorageService()).init();
  Get.put(ApiService());
  Get.put(SocketService());
  Get.put(AuthProvider());
  Get.put(RoomProvider());
  Get.put(ChatProvider());
  Get.put(WalletProvider());

  runApp(const YallaNsuwalefApp());
}

class YallaNsuwalefApp extends StatelessWidget {
  const YallaNsuwalefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'يلا نسوالف',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.fadeIn,
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/phone-auth', page: () => const PhoneAuthScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/room', page: () => const RoomScreen()),
        GetPage(name: '/voice-room', page: () => const VoiceRoomScreen()),
        GetPage(name: '/create-room', page: () => const CreateRoomScreen()),
        GetPage(name: '/discover', page: () => const DiscoverScreen()),
        GetPage(name: '/wallet', page: () => const WalletScreen()),
        GetPage(name: '/recharge', page: () => const RechargeScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/admin', page: () => const AdminScreen()),
      ],
    );
  }
}
