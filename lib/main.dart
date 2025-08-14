import 'package:ecomm_app/UI/screens/auth/login/login_screen.dart';
import 'package:ecomm_app/UI/screens/home/home_screen.dart';
import 'package:ecomm_app/utils/supabase_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EComm Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: loginCheck(),
    );
  }
}

loginCheck() {
  final Session? session = supabase.auth.currentSession;
  if (session != null) {
    return const HomeScreen();
  } else {
    return const LoginScreen();
  }
}
