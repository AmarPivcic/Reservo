import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/app.dart';
import 'package:reservo_organizer/src/providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child:  const MyApp(),
    ),
  );
}


