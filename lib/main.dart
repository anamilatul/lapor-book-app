import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book_app/firebase_options.dart';
import 'pages/AddFormPage.dart';
import 'pages/DashboardPage.dart';
import 'pages/DetailPage.dart';
import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'pages/SplashPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Lapor Book',
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),
      '/add': (context) => AddFormPage(),
      '/detail': (context) => const DetailPage(),
    },
  ));
}
