import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type_insert.dart';
import 'package:reservo_organizer/src/models/venue_request/venue_request_insert.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:reservo_organizer/src/screens/event_details_screen.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class NewEventScreen extends StatefulWidget{
  const NewEventScreen({super.key});
  
  @override
  State<StatefulWidget> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen>{

  final _formKey = GlobalKey<FormState>();

  late String _eventName;
  String? _eventDescription;
  int? _categoryId;
  int? _venueId; 
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  String? _image;
  int? _cityId;
  String? _categoryName;
  String? _cityName;
  String? _venueName;
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();


  List<TicketTypeInsert> _ticketTypes = [];

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final cap = context.read<CategoryProvider>();
    cap.getCategories();
    final cip = context.read<CityProvider>();
    cip.getCities();
  });
  _ticketTypes.add(TicketTypeInsert( 
      "",
      null,
      0,
      0,
    ));
}

void _addTicketType() {
  setState(() {
    _ticketTypes.add(TicketTypeInsert( 
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

Future<void> _fetchVenues(int? cityId, int? categoryId) async {
  final vp = context.read<VenueProvider>();
  await vp.getVenues(cityId, categoryId);
}

void _saveEvent() async {
  if (!_formKey.currentState!.validate()) return;

  _formKey.currentState!.save();

  if (_eventStartDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a start date")),
    );
    return;
  }

  if (_eventEndDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select an end date")),
    );
    return;
  }

  final ep = context.read<EventProvider>();

  final eventData = EventInsertUpdate(
    name: _eventName,
    description: _eventDescription,
    startDate: _eventStartDate!,
    endDate: _eventEndDate!,
    categoryId: _categoryId!,
    venueId: _venueId!,
    image: _image,
    ticketTypes: _ticketTypes,
  );

  final newEvent = await ep.insertEvent(eventData);
  newEvent.categoryName = _categoryName;
  newEvent.cityName = _cityName;
  newEvent.venueName = _venueName;
  newEvent.cityId = _cityId!;

  await ep.trainEventVectors();

  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => EventDetailsScreen(eventData: newEvent)
    )
  );
}

Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      _pickedImageFile = file;
      _image = base64Image;
    });
  }
}

Future<void> _pickStartDate() async {
  final now = DateTime.now();

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: now,
    lastDate: DateTime(2100),
  );
  if (pickedDate == null) return;

  TimeOfDay initialTime = const TimeOfDay(hour: 18, minute: 0);

  if (pickedDate.year == now.year &&
      pickedDate.month == now.month &&
      pickedDate.day == now.day) {
    final minHour = (now.hour + 2).clamp(0, 23);
    initialTime = TimeOfDay(hour: minHour, minute: now.minute);
  }

  final pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (pickedTime == null) return;

  if (pickedDate.year == now.year &&
      pickedDate.month == now.month &&
      pickedDate.day == now.day) {
    final minTime = now.add(const Duration(hours: 2));
    final pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (pickedDateTime.isBefore(minTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected time must be at least 2 hours from now")),
      );
      return;
    }
  }

  setState(() {
    _eventStartDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (_eventEndDate != null && _eventEndDate!.isBefore(_eventStartDate!)) {
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

  
  Future<void> _requestVenuePopUp() async {
    final _formKey = GlobalKey<FormState>();
    String? venueName;
    String? cityName;
    String? address;
    int? capacity;
    String? description;
    String? allowedCategories;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Request a new venue"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Venue Name"),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      onSaved: (v) => venueName = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "City Name"),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      onSaved: (v) => cityName = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Address"),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      onSaved: (v) => address = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Capacity"),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        final val = int.tryParse(v);
                        if (val == null || val <= 0) return "Must be > 0";
                        return null;
                      },
                      onSaved: (v) => capacity = int.tryParse(v ?? "0"),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Description (optional)"),
                      onSaved: (v) => description = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Allowed Categories (comma separated)"),
                      onSaved: (v) => allowedCategories = v,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final vp = context.read<VenueProvider>();
                try {
                  final requestInsert = VenueRequestInsert(
                    venueName: venueName!, 
                    cityName: cityName!, 
                    address: address!, 
                    capacity: capacity!, 
                    description: description,
                    allowedCategories: allowedCategories!
                  );

                  final request = await vp.requestVenue(requestInsert);

                  Navigator.of(ctx).pop();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Success!"),
                      content: Text("Venue request submitted for venue: ${request.venueName}"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                } catch (e) {

                  Navigator.of(ctx).pop();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Error!"),
                      content: Text("Error: $e"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },

              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final cityProvider = Provider.of<CityProvider>(context);
    final venueProvider = Provider.of<VenueProvider>(context);


    return MasterScreen(
      showBackButton: false,
      child:  SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Event Image", style: Theme.of(context).textTheme.headline6),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: _pickImage,
                    child: _pickedImageFile == null
                        ? Container(
                            height: 160,
                            width: 340,
                            color: Colors.grey[300],
                            child: const Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                          )
                        : Image.file(
                            _pickedImageFile!,
                            height: 160,
                            width: 340,
                            fit: BoxFit.cover,
                          ),
                  ),

                  const SizedBox(height: 20),
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
                    onChanged: (val) async {
                      setState(() {
                        _categoryId = val;
                        _categoryName = categoryProvider.categories.firstWhere((c) =>
                        c.id == val).name;
                        _venueId = null;
                        _venueName = null;
                      });
                      await _fetchVenues(_cityId, _categoryId);
                    },
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  DropdownButtonFormField<int>(
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
                        _cityName = cityProvider.cities
                            .firstWhere((c) => c.id == val)
                            .name;
                        _venueId = null;
                        _venueName = null;
                      });
                      await _fetchVenues(_cityId, _categoryId);
                    },
                    validator: (v) => v == null ? "Required" : null
                  ),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Venue"),
                    value:  venueProvider.venues.any((v) => v.id == _venueId) ? _venueId : null,
                    items: venueProvider.venues
                            .map((v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text(v.name),
                            )).toList(),
                    onChanged: (_cityId  == null || _categoryId == null)
                        ? null
                        : (val) => setState(() {
                            _venueId = val;
                            _venueName = venueProvider.venues
                                .firstWhere((v) => v.id == val)
                                .name;
                          }),
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed:_requestVenuePopUp,
                    child: const Text("Missing venue? Request here"),
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    title: Text(
                      _eventStartDate == null
                          ? "Select event start date and time"
                          : DateFormat('dd.MM.yyyy HH:mm').format(_eventStartDate!),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickStartDate,
                  ),

                  ListTile(
                    title: Text(
                      _eventEndDate == null
                            ? "Select event end date and time"
                            : DateFormat('dd.MM.yyyy HH:mm').format(_eventEndDate!)
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _eventStartDate == null ? null : _pickEndDate,
                    enabled: _eventStartDate != null,
                  ),

                  const SizedBox(height: 20),

                  Text("Ticket Types", style: Theme.of(context).textTheme.headline6,),

                  Column(
                    children: _ticketTypes.map((ticket) {
                      final index = _ticketTypes.indexOf(ticket);
                      return Card(
                        key: ValueKey(ticket),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              TextFormField(
                                key: ValueKey("name_${ticket.hashCode}"),
                                initialValue: ticket.name,
                                decoration: const InputDecoration(labelText: "Ticket Name"),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                onChanged: (value) => ticket.name = value,
                              ),
                              TextFormField(
                                key: ValueKey("desc_${ticket.hashCode}"),
                                initialValue: ticket.description,
                                decoration: const InputDecoration(labelText: "Description (optional)"),
                                onChanged: (value) => ticket.description = value,
                              ),
                              TextFormField(
                                key: ValueKey("price_${ticket.hashCode}"),
                                initialValue: ticket.price.toString(),
                                decoration: const InputDecoration(labelText: "Price"),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  final value = double.tryParse(v);
                                  if (value == null || value <= 0) return "Price must be greater than 0";
                                  return null;
                                },
                                onChanged: (value) => ticket.price = double.tryParse(value) ?? 0,
                              ),

                              TextFormField(
                                key: ValueKey("qty_${ticket.hashCode}"),
                                initialValue: ticket.quantity.toString(),
                                decoration: const InputDecoration(labelText: "Quantity"),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Required";
                                  final value = int.tryParse(v);
                                  if (value == null || value <= 0) return "Quantity must be greater than 0";
                                  return null;
                                },
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
        )
      ),
     );
  }

}
