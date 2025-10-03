import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reservo_organizer_scanner/src/providers/ticket_provider.dart';
import 'package:reservo_organizer_scanner/src/screens/master_screen.dart';
import 'package:reservo_organizer_scanner/src/models/ticket/ticket_response.dart';

class ScanScreen extends StatefulWidget {
  final int eventId;
  const ScanScreen({super.key, required this.eventId});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ticketProvider = TicketProvider();

  String? scannedCode;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final result = await controller.analyzeImage(file.path);

    if (result!.barcodes.isNotEmpty) {
      final code = result.barcodes.first.rawValue;
      if (code != null) {
        setState(() => scannedCode = code);
        _checkTicket(code);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No QR code found in image")),
      );
    }
  }

  Future<void> _checkTicket(String qrValue) async {
    try {
      final TicketResponse response =
          await ticketProvider.checkTicket(widget.eventId, qrValue);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(response.isValid ? "Valid Ticket" : "Invalid Ticket"),
          content: Text(response.message),
          actions: [
            if (response.isValid) ...[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _markTicketAsUsed(response.ticketId!);
                },
                child: const Text("Mark as Used"),
              ),
            ] else
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _markTicketAsUsed(int ticketId) async {
    try {
      await ticketProvider.markTicketAsUsed(ticketId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket marked as used")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark ticket as used: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      child: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final value = barcodes.first.rawValue;
                  if (value != null && value != scannedCode) {
                    setState(() => scannedCode = value);
                    _checkTicket(value);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(scannedCode == null
              ? "No QR scanned yet"
              : "Scanned: $scannedCode"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Upload QR from file"),
          ),
        ],
      ),
    );
  }
}
