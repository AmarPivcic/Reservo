import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

final _nameController = TextEditingController();
final _cityController = TextEditingController();
final _venueController = TextEditingController();
DateTime? _selectedDate;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    final ep = context.read<EventProvider>();
    ep.getEvents();
  });
}

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
    date: _selectedDate
  );
}

void _clearFilters() {
  setState(() {
    _nameController.clear();
    _venueController.clear();
    _cityController.clear();
    _selectedDate = null;
  });
  context.read<EventProvider>().getEvents();
}

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      showBackButton: false,
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
                            : ep.events.isEmpty
                            ? const Center(child: Text("No events found."))
                            : _EventGrid(events: ep.events)
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
                  "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
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
  const _EventGrid({required this.events});

  final List<Event> events;

  int _calcCrossAxisCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 1400) return 4;
    if (width >= 800) return 2;
    return 1;
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final cols = _calcCrossAxisCount(constraints.maxWidth);
      return GridView.builder(
        itemCount: events.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.7
        ),
         itemBuilder: (_, index) => _EventCard(event: events[index]),
      );
    });
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
    final city = event.cityName;
    final startDate = event.startDate;
    final dateText = startDate.toString();


    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          //TODO: Navigate to event edit screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "$venue${city.isNotEmpty ? ' - $city' : ''}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                )
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 6),
                Text(dateText)
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () {
                  //TODO: navigate to manage tickets screen
                }, 
                icon: Icon(Icons.edit_outlined), 
                label: Text("Manage")),
            )
          ],
        ),
      ),
    );
  }
}