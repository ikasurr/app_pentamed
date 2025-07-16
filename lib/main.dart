import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_routes.dart';
import '../../utils/constants.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi GetStorage
  await GetStorage.init();

  // Inisialisasi Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

// Helper global untuk akses mudah ke client Supabase
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pentamed',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
