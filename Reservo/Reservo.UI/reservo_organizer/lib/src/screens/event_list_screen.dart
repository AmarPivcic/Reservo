import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/cancelled_events_screen.dart';
import 'package:reservo_organizer/src/screens/draft_events_screen.dart';
import 'package:reservo_organizer/src/screens/event_edit_screen.dart';
import 'package:reservo_organizer/src/screens/home_screen.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';
import 'package:reservo_organizer/src/screens/new_event_screen.dart';
import 'package:reservo_organizer/src/screens/previous_events_screen.dart';
import '../models/event/event.dart';

class EventListScreen  extends StatefulWidget {
  final String state;
  final String title;

  const EventListScreen ({super.key, required this.state, required this.title});

  @override
  State<EventListScreen > createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {

final _nameController = TextEditingController();
final _cityController = TextEditingController();
final _venueController = TextEditingController();
DateTime? _selectedDate;

@override
void dispose() {
  _nameController.dispose();
  _cityController.dispose();
  _venueController.dispose();
  super.dispose();
}

Future<void> _pickDate() async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context, 
    initialDate: _selectedDate ?? now,
    firstDate: DateTime(now.year - 1), 
    lastDate: DateTime(now.year + 3)
  );

  if(picked != null)
  {
    setState(() => _selectedDate = picked);
  }
}

void _applyFilters() {
  final ep = context.read<EventProvider>();
  ep.getEvents(
    nameFilter: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    cityFilter: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
    venueFilter: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
    date: _selectedDate,
    state: widget.state
  );
}

void _clearFilters() {
  setState(() {
    _nameController.clear();
    _venueController.clear();
    _cityController.clear();
    _selectedDate = null;
  });
  context.read<EventProvider>().getEvents(state: widget.state);
}

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      showBackButton: false,
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.event, color: Colors.white),
          label: const Text("Active Events", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const PreviousEventsScreen()),
            );
          },
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text("Completed Events", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const CancelledEventsScreen()),
            );
          },
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Cancelled Events", style: TextStyle(color: Colors.white)),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const DraftEventsScreen()),
            );
          },
          icon: const Icon(Icons.drafts, color: Colors.white),
          label: const Text("Draft Events", style: TextStyle(color: Colors.white)),
        ),
      ],
      child: Consumer<EventProvider>(
        builder: (context, ep, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.25,
                    child: _FilterPanel(
                      nameController: _nameController,
                      cityController: _cityController,
                      venueController: _venueController,
                      selectedDate: _selectedDate,
                      onPickDate: _pickDate,
                      onApply: _applyFilters,
                      onClear: _clearFilters,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.75,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ep.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            :Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                const SizedBox(height: 16), // spacing between title and grid
                                Expanded(
                                  child: _EventGrid(events: ep.events, state: widget.state,),
                                ),
                              ],
                            ),
                    ),
                  )
                ],
              );
            }
          );
        },
      )
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.nameController, 
    required this.cityController, 
    required this.venueController, 
    required this.selectedDate, 
    required this.onPickDate, 
    required this.onApply, 
    required this.onClear, 
  });

  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController venueController;
  final DateTime? selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text("Filters", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Event name",
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: "City",
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: venueController,
            decoration: const InputDecoration(
              labelText: "Venue name",
              border: OutlineInputBorder()
            ),
          ),
          const SizedBox(height: 12,),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: "Date",
              border: OutlineInputBorder(),
            ),
            child: InkWell(
              onTap: onPickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  selectedDate == null ? "Any date" : 
                  DateFormat('dd.MM.yyyy').format(selectedDate!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(onPressed: onApply, 
                  icon: Icon(Icons.search), 
                  label: Text("Apply")
                  )
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(onPressed: onClear, 
                  icon: Icon(Icons.clear), 
                  label: Text("Clear")
                  )
                )
              ],
            )
        ],
      ),
    );
  }
}


class _EventGrid extends StatelessWidget {
  const _EventGrid({required this.events, required this.state});

  final List<Event> events;
  final String state;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return GridView.builder(
        itemCount: events.length + 1,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 340,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1
        ),
         itemBuilder: (_, index) {
          if(index < events.length) {
            return SizedBox(
              width: 340,
              child: _EventCard(event: events[index])
            );
          }
          else if (state == "active") {
            return SizedBox(
              width: 340,
              child: _AddEventCard(),
            );
          }
          else {
            return const SizedBox.shrink();
          }
         }
      );
    });
  }
}


class _AddEventCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder:(context) => const NewEventScreen())
            );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_rounded, size: 36),
              const SizedBox(height: 8),
              Text(
                "Add new event",
                style: Theme.of(context).textTheme.titleMedium,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget{

  const _EventCard({
    required this.event
  });
  
  final Event event;
  
  @override
  Widget build(BuildContext context) {

    final name = event.name ;
    final venue = event.venueName;
    final city = event.cityName ?? "";
    final startDate = event.startDate;
    final dateText = DateFormat('dd.MM.yyyy').format(startDate);
    Uint8List? imageBytes;

    if(event.image != null && event.image!.isNotEmpty)
    {
      imageBytes = base64Decode(event.image!);
    }

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push( 
            context, 
            MaterialPageRoute(
              builder: (_) => EventEditScreen(eventData: event, previousState: event.state,)
            )
          );

          if(result != null){
            await context.read<EventProvider>().getEvents(state: result);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: event.image != null && event.image!.isNotEmpty
              ? Image.memory(
                imageBytes!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                )
              : Image.asset(
                'lib/src/assets/images/LogoLight.png',
                height: 160,
                fit: BoxFit.cover,
              )
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 6),
                 Text(
                    "$venue${city.isNotEmpty ? ' - $city' : ''}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ) 
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 6),
                Text(dateText)
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(8),
                child: Icon(Icons.edit_outlined)
              )         
            )
          ],
        ),
      ),
    );
  }
}