import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_admin/src/providers/auth_provider.dart';
import 'package:reservo_admin/src/screens/home_screen.dart';
import 'package:reservo_admin/src/screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Reservo',
            theme: ThemeData.dark().copyWith(),
            home: authProvider.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}