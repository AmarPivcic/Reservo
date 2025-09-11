import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/app.dart';
import 'package:reservo_organizer/src/providers/auth_provider.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/providers/ticket_type_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1650, 880),
    minimumSize: Size(1650, 880),
    center: true,
    title: "Reservo",
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    alwaysOnTop: false
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

    await windowManager.setResizable(true);
    await windowManager.setMaximizable(true);
  });

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProvider(create: (_) => TicketTypeProvider())
      ],
      child:  const MyApp(),
    ),
  );
}


