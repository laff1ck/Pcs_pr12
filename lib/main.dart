import 'package:flutter/material.dart';
import 'package:pr_12/pages/home_page.dart';
import 'package:pr_12/pages/fav_page.dart';
import 'package:pr_12/pages/login_page.dart';
import 'package:pr_12/pages/prof_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ktvoojeulbcamadqhemn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0dm9vamV1bGJjYW1hZHFoZW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNzQ0MzUsImV4cCI6MjA0OTk1MDQzNX0.rMBwZoxCLnahIQz6LIaikS5Nxa2WgKFc2-OKgIqHBIw',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,

      title: 'Лавочка',
      home: FutureBuilder(
        future: Future.value(Supabase.instance.client.auth.currentSession),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data; // Получаем текущую сессию
          if (session == null) {
            return LoginPage(); // Пользователь не авторизован
          } else {
            return ProfPage(); // Пользователь авторизован
          }
        },
      ),

    );
  }
}