import 'package:flutter/material.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      showBackButton: false,
      child: Center(
        child: Text(
          "Welcome to Reservo",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}