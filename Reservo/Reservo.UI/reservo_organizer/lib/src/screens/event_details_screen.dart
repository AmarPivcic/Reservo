import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reservo_organizer/src/models/event/event.dart';
import 'package:reservo_organizer/src/providers/event_provider.dart';
import 'package:reservo_organizer/src/screens/event_edit_screen.dart';
import 'package:reservo_organizer/src/screens/home_screen.dart';
import 'package:reservo_organizer/src/screens/master_screen.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  
  final Event eventData;
  const EventDetailsScreen({super.key, required this.eventData});

  @override
  State<StatefulWidget> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {

void _editEvent() async {
  Navigator.push(
    context, 
    MaterialPageRoute(
      builder: (_) => EventEditScreen(eventData: widget.eventData, previousState: widget.eventData.state)
    )
  );
}

Future<void> _activateEvent() async{
  final ep = context.read<EventProvider>();
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
  } 
}

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

    return MasterScreen(
      showBackButton: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center (
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.eventData.image != null && widget.eventData.image!.isNotEmpty
                        ? Image.network(
                            widget.eventData.image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  widget.eventData.name,
                  style: Theme.of(context).textTheme.headline5,
                ),

                const SizedBox(height: 8),

                if (widget.eventData.description.isNotEmpty)
                  Text(
                    widget.eventData.description,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                else
                  Text(
                        "No description",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                const SizedBox(height: 12),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Start Date:", dateFormatter.format(widget.eventData.startDate)),
                        _infoRow("End Date:", dateFormatter.format(widget.eventData.endDate)),
                        _infoRow("Category:", widget.eventData.categoryName ?? "-"),
                        _infoRow("Venue:", widget.eventData.venueName ?? "-"),
                        _infoRow("City:", widget.eventData.cityName ?? "-"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Tickets",
                  style: Theme.of(context).textTheme.headline6,
                ),

                const SizedBox(height: 8),

                Column(
                  children: widget.eventData.ticketTypes.map((ticket) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (ticket.description != null && ticket.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(ticket.description!),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text("Price: \$${ticket.price.toStringAsFixed(2)}"),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text("Quantity: ${ticket.quantity}"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    OutlinedButton(
                      onPressed: _editEvent,
                      child: const Text("Edit"),
                    ),

                    ElevatedButton(
                      onPressed: _activateEvent,
                      child: const Text("Activate Event"),
                    )
                  ],
                )
              ],
            ),
          )
        )
      ), 
    );
  }

   Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

}