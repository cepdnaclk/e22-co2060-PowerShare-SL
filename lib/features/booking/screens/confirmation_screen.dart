import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import 'payment_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final ChargerModel charger;
  final DateTime date;
  final TimeOfDay time;
  final double durationHours;
  final double totalPrice;
  final double estimatedKwh;

  const ConfirmationScreen({
    super.key,
    required this.charger,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.totalPrice,
    required this.estimatedKwh,
  });

  String get _durationLabel {
    final totalMinutes = (durationHours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}hr';
    return '${h}hr ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final timeStr = time.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Booking Summary',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(Icons.ev_station, 'Charger', charger.name),
                    const Divider(),
                    _row(Icons.location_on, 'Location', charger.address),
                    const Divider(),
                    _row(Icons.person, 'Owner', charger.ownerName),
                    const Divider(),
                    _row(Icons.calendar_today, 'Date', dateStr),
                    const Divider(),
                    _row(Icons.access_time, 'Time', timeStr),
                    const Divider(),
                    _row(Icons.timer, 'Duration', _durationLabel),
                    const Divider(),
                    _row(Icons.bolt, 'Est. Energy',
                        '${estimatedKwh.toStringAsFixed(2)} kWh'),
                    const Divider(),
                    _row(Icons.electric_bolt, 'Rate',
                        'Rs. ${charger.pricePerKwh.toStringAsFixed(0)}/kWh'),
                    const Divider(),
                    _row(Icons.payment, 'Total Payable',
                        'Rs. ${totalPrice.toStringAsFixed(2)}',
                        isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Final cost is based on actual kWh consumed at session end.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // → Payment Screen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        charger: charger,
                        date: date,
                        time: time,
                        durationHours: durationHours,
                        estimatedKwh: estimatedKwh,
                        totalPrice: totalPrice,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text('Proceed to Payment',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal
                  ? const Color(0xFF1E3A5F)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}