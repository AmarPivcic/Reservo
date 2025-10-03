import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer_scanner/app.dart';
import 'package:reservo_organizer_scanner/src/providers/auth_provider.dart';
import 'package:reservo_organizer_scanner/src/providers/event_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: const MyApp(),
    )
  );
}

