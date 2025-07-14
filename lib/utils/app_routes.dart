import 'package:get/get.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/obat/obat_form.dart';
import '../halaman_awal.dart';
import 'package:app_pentamed/screens/splash_screen.dart';
import 'package:app_pentamed/screens/obat/detail_obat.dart';
import 'package:app_pentamed/screens/obat/obat_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String laporan = '/laporan';
  static const String transaksi = '/transaksi';
  static const String index = '/index';
  static const String detailobat = '/detailobat';
  static const String obat = '/obat';

  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: index, page: () => const HalamanAwal()),

    GetPage(
      name: '/obatform',
      page: () => const FormObatScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: '/obatdetail', page: () => const DetailObat()),
    GetPage(name: '/obatlist', page: () => const ObatListScreen()),
  ];
}
