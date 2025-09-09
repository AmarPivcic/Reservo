import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/models/event/event_insert_update.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type.dart';
import 'package:reservo_organizer/src/models/ticket_type/ticket_type_insert.dart';
import 'package:reservo_organizer/src/providers/category_provider.dart';
import 'package:reservo_organizer/src/providers/city_provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/providers/venue_provider.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event eventData;
  const EventDetailsScreen({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventDetailsScreen> {

  final _formKey = GlobalKey<FormState>();

  late String _eventName;
  String? _eventDescription;
  int? _categoryId;
  int? _venueId;
  String? _eventImage; 
  DateTime? _eventStartDate;
  DateTime? _eventEndDate;
  int? _cityId;

  List<TicketType> _ticketTypes = [];

  late String previousState;
  bool _isSaving = false;
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final cap = context.read<CategoryProvider>();
    cap.getCategories();
    final cip = context.read<CityProvider>();
    cip.getCities();
  });

  _eventName = widget.eventData.name;
  _eventDescription = widget.eventData.description;
  _eventStartDate = widget.eventData.startDate;
  _eventEndDate = widget.eventData.endDate;
  _categoryId = widget.eventData.categoryId;
  _venueId = widget.eventData.venueId;
  _eventImage = widget.eventData.image;
  _ticketTypes = widget.eventData.ticketTypes;

  previousState = widget.eventData.state;

  if (widget.eventData.state.toLowerCase() != "draft") {
     _markDraft();
  }
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
    if (previousState.toLowerCase() == 'active') {
      await ep.setEventActive(widget.eventData.id);
    } else {
      await ep.setEventDraft(widget.eventData.id);
    }
  } catch (e) {
    throw Exception("Failed to revert state: $e");
  } finally {
    Navigator.pop(context, false);
  }
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
    });
}

Future<void> _activateEvent() async{
  final ep = context.read<EventProvider>();
  setState(() {
    _isActivating = true;
  });

  try {
    final updated = await ep.activateEvent(widget.eventData.id);

    setState(() {
      widget.eventData.state = updated.state;
    });

    await showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        title: const Text("Activated"),
        content: const Text("Event has been activated"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
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
    _isSaving = true;
  });

  try {
    final updated = await ep.updateEvent(widget.eventData.id, dto);

    setState(() {
      widget.eventData.name = updated.name;
      widget.eventData.description = updated.description;
      widget.eventData.startDate = updated.startDate;
      widget.eventData.endDate = updated.endDate;
      widget.eventData.categoryId = updated.categoryId;
      widget.eventData.venueId = updated.venueId;
      widget.eventData.venueName = updated.venueName;
      widget.eventData.cityName = updated.cityName;
      widget.eventData.ticketTypes = updated.ticketTypes;
      widget.eventData.categoryName = updated.categoryName;
    });

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
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final cityProvider = context.watch<CityProvider>();
    final venueProvider = context.watch<VenueProvider>();

    return MasterScreen(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      OutlinedButton(
                        onPressed: _isSaving ? null : _revertStateAndClose, 
                        child: const Text("Cancel")
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges, 
                        child: const Text("Save")
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                      onPressed: widget.eventData.state == "active" || _isActivating ? null : _activateEvent,
                      child: _isActivating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Activate"),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),

              if (_eventImage != null && _eventImage!.isNotEmpty)
                Container(
                  height: 160,
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                child: const Center(child: Text("Image preview (not editable)")),
                )
              else
                Container(height: 160, width: double.infinity, color: Colors.grey[100], child: Center(child: Text("No image"))),

                const SizedBox(height: 12),

              TextFormField(
                initialValue: _eventName,
                decoration: const InputDecoration(labelText: "Event name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => _eventName = v!.trim(),
              ),

              const SizedBox(height: 8),
                TextFormField(
                initialValue: _eventDescription,
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (v) => _eventDescription = v,
              ),

              const SizedBox(height: 8),
            
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Category"), 
                value: _categoryId,
                items: categoryProvider.categories
                    .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                validator: (v) => v == null ? "Required" : null,
              ),
              
              const SizedBox(height: 8),

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
                    _venueId = null;
                  });
                  await venueProvider.getVenuesByCity(val!);
                },
                validator: (v) => v == null ? "Required" : null
              ),

              const SizedBox(height: 8),

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

              const SizedBox(height: 12),

              ListTile(
                title: Text(_eventStartDate == null ? 'Select Start' : DateFormat('dd.MM.yyyy HH:mm').format(_eventStartDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              ListTile(
                title: Text(_eventEndDate == null ? 'Select End' : DateFormat('dd.MM.yyyy HH:mm').format(_eventEndDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _eventStartDate == null ? null : _pickEndDate,
                enabled: _eventStartDate != null,
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
                            initialValue: ticket.name,
                            decoration: const InputDecoration(labelText: "Ticket Name"),
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.name = value,
                          ),

                          TextFormField(
                            initialValue: ticket.description,
                            decoration: const InputDecoration(labelText: "Description (optional)"),
                            onChanged: (value) => ticket.description = value,
                          ),

                          TextFormField(
                            initialValue: ticket.price.toString(),
                            decoration: const InputDecoration(labelText: "Price"),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.price = double.tryParse(value) ?? 0,
                          ),

                          TextFormField(
                            initialValue: ticket.quantity.toString(),
                            decoration: const InputDecoration(labelText: "Quantity"),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            onChanged: (value) => ticket.quantity = int.tryParse(value) ?? 0,
                          ),

                          if(index > 0)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _removeTicketType(index), 
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
                  onPressed: _addTicketType,
                  icon: const Icon(Icons.add),
                  label: const Text("Add another ticket type"),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}