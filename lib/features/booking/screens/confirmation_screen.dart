import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../map/screens/map_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final ChargerModel charger;
  final DateTime date;
  final TimeOfDay time;
  final int durationHours;
  final double totalPrice;

  const ConfirmationScreen({
    super.key,
    required this.charger,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Booking Summary',
              style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow(Icons.ev_station, 'Charger', charger.name),
                    const Divider(),
                    _buildRow(
                        Icons.location_on, 'Location', charger.address),
                    const Divider(),
                    _buildRow(Icons.person, 'Owner', charger.ownerName),
                    const Divider(),
                    _buildRow(
                      Icons.calendar_today,
                      'Date',
                      '${date.day}/${date.month}/${date.year}',
                    ),
                    const Divider(),
                    _buildRow(
                        Icons.access_time, 'Time', time.format(context)),
                    const Divider(),
                    _buildRow(
                      Icons.timer,
                      'Duration',
                      '$durationHours hour${durationHours > 1 ? 's' : ''}',
                    ),
                    const Divider(),
                    _buildRow(
                      Icons.payment,
                      'Total',
                      'Rs. ${totalPrice.toInt()}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Booking Confirmed! 🎉'),
                      content: Text(
                        'Your booking at ${charger.name} is confirmed!\n\nDate: ${date.day}/${date.month}/${date.year}\nTime: ${time.format(context)}\nDuration: $durationHours hr\nTotal: Rs. ${totalPrice.toInt()}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MapScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Back to Map'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm Booking',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF1E3A5F) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}