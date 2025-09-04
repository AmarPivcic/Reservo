import 'package:flutter/cupertino.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class NewEventScreen extends StatefulWidget{
  const NewEventScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen>{
  @override
  Widget build(Object context) {
    return MasterScreen(
      showBackButton: true,
      child: const Center(
        child: Text("Add new event screen."),
      ),
     );
  }

}
