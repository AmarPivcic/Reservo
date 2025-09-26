import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type_insert.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/providers/ticket_type_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:reservo_organizer/src/screens/home_screen.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';
import 'package:intl/intl.dart';

class EventEditScreen extends StatefulWidget {
  final Event eventData;
  final String previousState;
  const EventEditScreen({super.key, required this.eventData, required this.previousState});

  @override
  State<StatefulWidget> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {

  final _formKey = GlobalKey<FormState>();

  late String _eventName;
  String? _eventDescription;
  int? _categoryId;
  int? _venueId;
  String? _eventImage; 
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  int? _cityId;
  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  List<TicketType> _ticketTypes = [];

  bool _isActivating = false;
  bool _isSaved = false;
  late bool isEditable;

  @override
  void initState() {
    super.initState();

    isEditable = widget.previousState.toLowerCase() == "active" ||
                  widget.previousState.toLowerCase() == "draft";

    _eventName = widget.eventData.name;
    _eventDescription = widget.eventData.description;
    _eventStartDate = widget.eventData.startDate;
    _eventEndDate = widget.eventData.endDate;
    _categoryId = widget.eventData.categoryId;
    _venueId = widget.eventData.venueId;
    _eventImage = widget.eventData.image;
    _cityId = widget.eventData.cityId;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final cap = context.read<CategoryProvider>();
      cap.getCategories();
      final cip = context.read<CityProvider>();
      cip.getCities();

      if (_cityId != null && _categoryId != null) {
        await context.read<VenueProvider>().getVenues(_cityId, _categoryId);
      }

      _fetchTickets();
    });

  if (widget.previousState.toLowerCase() != "draft") {
     _markDraft();
  }

}

Future<void> _fetchTickets() async {
  final ticketTypeProvider = context.read<TicketTypeProvider>();
  final ticketTypes = await ticketTypeProvider.getTicketTypesForEvent(widget.eventData.id);

  setState(() {
    _ticketTypes = ticketTypes;
  });
}

Future<void> _markDraft() async {
  final ep = context.read<EventProvider>();
  final updated = await ep.setEventDraft(widget.eventData.id);
  setState(() {
    widget.eventData.state = updated.state;
  });
}

Future<void> _revertStateAndClose() async {
  try {
    final ep = context.read<EventProvider>();
    if (widget.previousState.toLowerCase() == 'active') {
      await ep.setEventActive(widget.eventData.id);
    } else if (widget.previousState.toLowerCase() == 'draft') {
      await ep.setEventDraft(widget.eventData.id);
    } else if (widget.previousState.toLowerCase() == 'completed') {
      await ep.setEventComplete(widget.eventData.id);
    } else if (widget.previousState.toLowerCase() == 'cancelled') {
      await ep.cancelEvent(widget.eventData.id);
    }
  } catch (e) {
    throw Exception("Failed to revert state: $e");
  } finally {
    Navigator.pop(context, widget.previousState);
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
      _isSaved = false;
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
      _isSaved = false;
    });
  }

  Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      _pickedImageFile = file;
      _eventImage = base64Image;
      _isSaved = false;
    });
  }
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
    if(_ticketTypes.length <= 1) return;
    setState(() {
      _ticketTypes.removeAt(index);
      _isSaved = false;
    });
}

Future<void> _activateEvent() async{
  final ep = context.read<EventProvider>();
  setState(() {
    _isActivating = true;
  });

  try {
    final updated = await ep.setEventActive(widget.eventData.id);

    setState(() {
      widget.eventData.state = updated.state;
    });

    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Activated"),
        content: const Text("Event has been activated"),
        actions: [TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()), 
              (route) => false);
            }, child: const Text("OK"))],
      )
    );
  } catch (e) {
    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text("Event activation failed: $e"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      )
    );
  } finally {
    setState(() {
      _isActivating = false;
    });
  }
}

Future<void> _saveChanges() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  final ep = context.read<EventProvider>();

  final ticketTypeInsert = _ticketTypes.map((t) {
    return TicketTypeInsert(
      t.name,
      t.description,
      t.price,
      t.quantity
    );
  }).toList();

  final dto = EventInsertUpdate(
    name: _eventName,
    description: _eventDescription,
    startDate: _eventStartDate!,
    endDate: _eventEndDate!,
    categoryId: _categoryId!,
    venueId: _venueId!,
    image: _eventImage,
    ticketTypes: ticketTypeInsert
  );

  setState(() {
    _isSaved = true;
  });

  try {
    await ep.updateEvent(widget.eventData.id, dto);

    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Saved"),
        content: const Text("Event updated successfully."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))      
        ],
      )
    );
  } catch (e) {
    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text("Failed to save changes: $e"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ));
  }
}

Future<void> _deleteEventPopUp() async {
  showDialog(
    context: context, 
    builder: (_) => AlertDialog(
      title: const Text("Warning!"),
      content: const Text("If you delete this event, you will not be able to recover it! All users that bought tickets will be refunded!"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        OutlinedButton(onPressed: () {_deleteEvent(); Navigator.pop(context);}, child: const Text("Delete event"), style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),),  
      ],
    )
  );
}

Future<void> _deleteEvent() async {
  final ep = context.read<EventProvider>();
  try {
    await ep.deleteEvent(widget.eventData.id);
    await showDialog(
      context: context, 
      builder: (dialogContext) => AlertDialog(
        title: const Text("Deleted"),
        content: const Text("Event deleted successfully."),
        actions: [
         TextButton(onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false
            );
            }, child: const Text("OK"))
        ],
      )
    );
  } catch (e) {
    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text("Failed to delete the event: $e"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            }, child: const Text("OK"))
        ],
      ));
  } 
}

Future<void> _cancelEventPopUp() async {
  showDialog(
    context: context, 
    builder: (_) => AlertDialog(
      title: const Text("Warning!"),
      content: const Text("If you cancel this event, you will not be able to activate it again!"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        OutlinedButton(onPressed: () {_cancelEvent(); Navigator.pop(context);}, child: const Text("Cancel event"), style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),),  
      ],
    )
  );
}

Future<void> _cancelEvent() async {
  final ep = context.read<EventProvider>();
  try {
    await ep.cancelEvent(widget.eventData.id);
    await showDialog(
      context: context, 
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cancelled"),
        content: const Text("Event cancelled successfully."),
        actions: [
         TextButton(onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false
            );
            }, child: const Text("OK"))
        ],
      )
    );
  } catch (e) {
    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text("Failed to cancel the event: $e"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            }, child: const Text("OK"))
        ],
      ));
  } 
}

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final cityProvider = context.watch<CityProvider>();
    final venueProvider = context.watch<VenueProvider>();

    return MasterScreen(
      showBackButton: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Edit event", style: Theme.of(context).textTheme.headlineMedium),
                      Row(
                        children: [
                          if(widget.previousState.toLowerCase() == "active")
                            OutlinedButton(
                              onPressed: _cancelEventPopUp,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Cancel event"),
                            ),
                          const SizedBox(width: 8),
                          if(isEditable)
                            OutlinedButton(
                              onPressed: _deleteEventPopUp,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Delete event"),
                            ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: isEditable
                            ? "Closes the screen. If changes are saved, event stays as draft. If event is not saved, changes are discarded."
                            : "" ,
                            child: OutlinedButton(
                              onPressed: _revertStateAndClose,
                              child: const Text("Close"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if(isEditable)
                          ElevatedButton(
                            onPressed: _isSaved ? null : _saveChanges, 
                            child: const Text("Save")
                          ),
                          const SizedBox(width: 8),
                          if(isEditable)
                            ElevatedButton(
                            onPressed: widget.eventData.state == "active" || _isActivating ? null : _activateEvent,
                            child: _isActivating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Activate"),
                            ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: isEditable ? _pickImage : null,
                    child: _pickedImageFile != null
                    ? Image.file(
                          _pickedImageFile!,
                          height: 180,
                          width: 240,
                          fit: BoxFit.cover,
                        )
                      : (_eventImage == null || _eventImage!.isEmpty 
                          ? Container(
                              height: 180,
                              width: 220,
                              color: Colors.grey[300],
                              child: const Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                            )
                          : Image.memory(
                              base64Decode(_eventImage!),
                              height: 180,
                              width: 220,
                              fit: BoxFit.cover,
                            ))
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    enabled: isEditable,
                    initialValue: _eventName,
                    decoration: const InputDecoration(labelText: "Event name"),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    onSaved: (v) => _eventName = v!.trim(),
                    onChanged: (_) => setState(() => _isSaved = false),
                  ),

                  const SizedBox(height: 8),
                    TextFormField(
                    enabled: isEditable,
                    initialValue: _eventDescription,
                    decoration: const InputDecoration(labelText: "Description"),
                    onSaved: (v) => _eventDescription = v,
                    onChanged: (_) => setState(() => _isSaved = false),
                  ),

                  const SizedBox(height: 8),
                
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Category"), 
                    value:  categoryProvider.categories.any((c) => c.id == _categoryId) ? _categoryId : null,
                    items: categoryProvider.categories
                        .map((c) => DropdownMenuItem<int>(
                          value: c.id, 
                          child: Text(c.name)))
                        .toList(),
                    onChanged: isEditable 
                      ? (val) async { 
                        setState(() {
                          _categoryId = val;
                          _isSaved = false;
                          _venueId = null;
                        });
                        await venueProvider.getVenues(_cityId, _categoryId);
                        } 
                      :null,
                    validator: (v) => v == null ? "Required" : null,
                  ),
                  
                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "City"),
                    value: cityProvider.cities.any((c) => c.id == _cityId) ? _cityId : null,
                    items: cityProvider.cities
                        .map((c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.name),
                            ))
                        .toList(),
                    onChanged: isEditable
                        ? (val) async {
                            setState(() {
                              _cityId = val;
                              _venueId = null;
                              _isSaved = false;
                            });
                            await venueProvider.getVenues(_cityId, _categoryId);
                          }
                        : null,
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Venue"),
                    value:  venueProvider.venues.any((v) => v.id == _venueId) ? _venueId : null,
                    items: venueProvider.venues
                            .map((v) => DropdownMenuItem<int>(
                            value: v.id,
                            child: Text(v.name),
                            )).toList(),
                    onChanged:(isEditable && _cityId != null)
                        ? (val) { 
                      setState(() {
                        _venueId = val;
                        _isSaved = false;
                      });
                    }
                    : null,
                    validator: (v) => v == null ? "Required" : null,
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    title: Text(_eventStartDate == null ? 'Select Start' : DateFormat('dd.MM.yyyy HH:mm').format(_eventStartDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickStartDate,
                    enabled: isEditable,
                  ),
                  ListTile(
                    title: Text(_eventEndDate == null ? 'Select End' : DateFormat('dd.MM.yyyy HH:mm').format(_eventEndDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _eventStartDate == null ? null : _pickEndDate,
                    enabled: _eventStartDate != null && isEditable,
                  ),
                  
                  const SizedBox(height: 20),

                  Text("Ticket Types", style: Theme.of(context).textTheme.headlineSmall),
                  
                  const SizedBox(height: 8),        

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
                                enabled: isEditable,
                                initialValue: ticket.name,
                                decoration: const InputDecoration(labelText: "Ticket Name"),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                onChanged: (val) { 
                                  setState(() {
                                    ticket.name = val;
                                    _isSaved = false;
                                  });
                                },
                              ),

                              TextFormField(
                                enabled: isEditable,
                                initialValue: ticket.description,
                                decoration: const InputDecoration(labelText: "Description (optional)"),
                                onChanged: (val) { 
                                  setState(() {
                                    ticket.description = val;
                                    _isSaved = false;
                                  });
                                }
                              ),

                              TextFormField(
                                enabled: isEditable,
                                initialValue: ticket.price.toString(),
                                decoration: const InputDecoration(labelText: "Price"),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                onChanged: (val) { 
                                  setState(() {
                                    ticket.price = double.tryParse(val) ?? 0.0;
                                    _isSaved = false;
                                  });
                                },
                              ),

                              TextFormField(
                                enabled: isEditable,
                                initialValue: ticket.quantity.toString(),
                                decoration: const InputDecoration(labelText: "Quantity"),
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                                onChanged: (val) { 
                                  setState(() {
                                    ticket.quantity = int.tryParse(val) ?? 0;
                                    _isSaved = false;
                                  });
                                },
                              ),

                              if(index > 0)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => isEditable ? _removeTicketType(index) : null, 
                                    icon: const Icon(Icons.remove_circle, color: Colors.red), 
                                    label: const Text("Remove")
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: isEditable ? _addTicketType : null,
                      icon: const Icon(Icons.add),
                      label: const Text("Add another ticket type"),
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}