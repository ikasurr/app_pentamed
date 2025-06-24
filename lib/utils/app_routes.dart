// lib/utils/app_routes.dart

import 'package:get/get.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/obat/obat_screen.dart';
import '../../screens/obat/obat_form.dart';
import '../../screens/profile/profile_screen.dart';
import '../halaman_awal.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String obat = '/obat';
  static const String laporan = '/laporan';
  static const String profile = '/profile';
  static const String transaksi = '/transaksi';
  static const String index = '/index';

  static final routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: obat, page: () => const ObatListScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: index, page: () => const HalamanAwal()),
    GetPage(
      name: '/obatform',
      page: () => const FormObatScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
