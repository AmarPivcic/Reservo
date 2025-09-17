import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_client/src/providers/category_provider.dart';
import 'package:reservo_client/src/screens/master_screen.dart';



class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final ep = context.read<CategoryProvider>();
    ep.getCategories();
  });
}

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Center(
        child: Column(
          children: [
            Text("Home Screen")
          ],
        ),
      )
      );
  }
}