import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type_insert.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:reservo_organizer/src/screens/event_details_screen.dart';
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
    _ticketTypes.add(TicketType(
      0, 
      "",
      null,
      0,
      0,
      ));
  });
}

void _removeTicketType(int index) {
    setState(() {
      _ticketTypes.removeAt(index);
    });
  }

Future<void> _fetchVenuesForCity(int cityId) async {
  final vp = context.read<VenueProvider>();
  await vp.getVenuesByCity(cityId);
}

void _saveEvent() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  final ep = context.read<EventProvider>();


  final eventData = EventInsertUpdate(
    name: _eventName!,
    description: _eventDescription,
    startDate: _eventStartDate!,
    endDate: _eventEndDate!,
    categoryId: _categoryId!,
    venueId: _venueId!,
    image: _image,
    ticketTypes: _ticketTypes.map((t) => TicketTypeInsert(
      t.name,
      t.description,
      t.price,
      t.quantity,
    )).toList(),
    );

  final newEvent = await ep.insertEvent(eventData);
    
  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => EventDetailsScreen(eventData: newEvent)
    )
  );
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
              Text("Event Info", style: Theme.of(context).textTheme.headline6),
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
                onChanged: (val) async {
                  setState(() {
                    _cityId = val;
                    _venueId = null;
                  });
                  await _fetchVenuesForCity(val!);
                },
                validator: (v) => v == null ? "Required" : null
              ),

              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Venue"),
                value: _venueId,
                items: venueProvider.venues
                        .map((v) => DropdownMenuItem<int>(
                         value: v.id,
                         child: Text(v.name),
                        )).toList(),
                onChanged: _cityId == null
                    ? null
                    : (val) => setState(() => _venueId = val),
                validator: (v) => v == null ? "Required" : null,
              ),

              ListTile(
                title: Text(
                  _eventStartDate == null
                      ? "Select event start date and time"
                      : "Start: $_eventStartDate",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),

              ListTile(
                title: Text(
                  _eventEndDate == null
                        ? "Select event end date and time"
                        : "Start: $_eventEndDate"
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndDate,
                enabled: _eventStartDate != null,
              ),

              const SizedBox(height: 20),

              Text("Ticket Types", style: Theme.of(context).textTheme.headline6,),

              Column(
                children: _ticketTypes.asMap().entries.map((e) {
                  int index = e.key;
                  var ticket = e.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: "Ticket Name"),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.name = value,
                          ),

                          TextFormField(
                            decoration: const InputDecoration(labelText: "Description (optional)"),
                            onChanged: (value) => ticket.description = value,
                          ),

                          TextFormField(
                            decoration: const InputDecoration(labelText: "Price"),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.price = double.tryParse(value) ?? 0,
                          ),

                          TextFormField(
                            decoration: const InputDecoration(labelText: "Quantity"),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.quantity = int.tryParse(value) ?? 0,
                          ),

                          if(index > 0)
                            TextButton.icon(
                              onPressed: () => _removeTicketType(index), 
                              icon: const Icon(Icons.remove_circle, color: Colors.red), 
                              label: const Text("Remove")
                              ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addTicketType,
                  icon: const Icon(Icons.add),
                  label: const Text("Add another ticket type"),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),

                  ElevatedButton(
                    onPressed: _saveEvent,
                    child: const Text("Save Event"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
     );
  }

}
