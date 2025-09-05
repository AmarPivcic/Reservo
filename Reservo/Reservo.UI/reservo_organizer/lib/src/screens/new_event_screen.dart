import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_organizer/src/models/venue/venue.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';


class NewEventScreen extends StatefulWidget{
  const NewEventScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen>{

  final _formKey = GlobalKey<FormState>();

  String? _eventName;
  String? _eventDescription;
  int? _categoryId;
  int? _venueId;
  String? _eventImage; 
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  TicketType? newTicket;
  String? _image;
  int? _cityId;

  List<TicketType> _ticketTypes = [];

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final cap = context.read<CategoryProvider>();
    cap.getCategories();
    final cip = context.read<CityProvider>();
    cip.getCities();
  });
}

void _addTicketType() {
  setState(() {
    _ticketTypes.add(newTicket!);
  });
}

void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }

Future<void> _fetchVenuesForCity(int cityId) async {
  final vp = context.read<VenueProvider>();
  vp.getVenuesByCity(cityId);

  setState(() {
      _venueId = null;
    });
}

void _saveEvent() {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  final eventData = {
    "name": _eventName,
    "description": _eventDescription,
    "startDate": _eventStartDate?.toIso8601String(),
    "endDate": _eventEndDate?.toIso8601String(),
    "categoryId": _categoryId,
    "venueId": _venueId,
    "image": _image
  };

  // Navigator.push(
  //   context, 
  //   MaterialPageRoute(builder: (_) =>)
  //   );
}

Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (pickedTime == null) return;

    final fullDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _eventStartDate = fullDate;
      if (_eventEndDate != null && _eventEndDate!.isBefore(fullDate)) {
        _eventEndDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    if (_eventStartDate == null) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventStartDate!,
      firstDate: _eventStartDate!,
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
    if (pickedTime == null) return;

    final fullDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (fullDate.isBefore(_eventStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date can't be before start date")),
      );
      return;
    }

    setState(() {
      _eventEndDate = fullDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);
    final venueProvider = Provider.of<VenueProvider>(context);


    return MasterScreen(
      showBackButton: true,
      child:  SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Evenjt Info", style: Theme.of(context).textTheme.headline6),
              TextFormField(
                decoration: const InputDecoration(labelText: "Event Name"),
                validator: (v) =>
                      v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => _eventName = v!,
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (v) => _eventDescription = v!
              ),

              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Category"),
                value: _categoryId,
                items: categoryProvider.categories
                       .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name)
                       )).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                validator: (v) => v == null ? "Required" : null,
              ),

              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "City"),
                value: _cityId,
                items: cityProvider.cities
                       .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name)
                       )).toList(),
                onChanged: (val) => _fetchVenuesForCity(val!),
                validator: (v) => v == null ? "Required" : null
              )
            ],
          ),
        ),
      ),
     );
  }

}
