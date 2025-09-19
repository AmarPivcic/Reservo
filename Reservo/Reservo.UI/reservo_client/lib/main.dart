import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/app.dart';
import 'package:reservo_client/src/providers/auth_provider.dart';
import 'package:reservo_client/src/providers/category_provider.dart';
import 'package:reservo_client/src/providers/city_provider.dart';
import 'package:reservo_client/src/providers/event_provider.dart';
import 'package:reservo_client/src/providers/ticket_type_provider.dart';
import 'package:reservo_client/src/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TicketTypeProvider()),
      ],
      child:  const MyApp(),
    ),
  );
}
