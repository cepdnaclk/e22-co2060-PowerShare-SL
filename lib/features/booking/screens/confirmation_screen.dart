import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/api_service.dart';
import '../../map/screens/map_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final ChargerModel charger;
  final DateTime date;
  final TimeOfDay time;
  final double durationHours;   // ← double (supports 0.5, 1.5 etc)
  final double estimatedKwh;    // ← kWh estimate
  final double totalPrice;

  const ConfirmationScreen({
    super.key,
    required this.charger,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.estimatedKwh,
    required this.totalPrice,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isBooking = false;
  static const double _platformFeePercent = 0.05; // 5% platform fee

  double get _platformFee => widget.totalPrice * _platformFeePercent;
  double get _grandTotal => widget.totalPrice + _platformFee;

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    final dateStr = '${widget.date.day}/${widget.date.month}/${widget.date.year}';
    final timeStr = widget.time.format(context);

    final result = await ApiService.createBooking(
      chargerId: widget.charger.id,
      chargerName: widget.charger.name,
      chargerAddress: widget.charger.address,
      date: dateStr,
      time: timeStr,
      durationHours: widget.durationHours.toInt(),
      totalPrice: _grandTotal,
    );

    setState(() => _isBooking = false);
    if (!mounted) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Booking Confirmed!'),
          ]),
          content: Text(
            'ඔබේ booking confirm වුණා!\n\n'
            '📍 ${widget.charger.name}\n'
            '📅 $dateStr at ${timeStr}\n'
            '⏱ ${widget.durationHours}h • ${widget.estimatedKwh.toStringAsFixed(1)} kWh\n'
            '💰 Rs. ${_grandTotal.toStringAsFixed(0)}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
                (route) => false,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Map'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Booking failed. Try again.'),
        backgroundColor: Colors.red,
        action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _confirmBooking),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${widget.date.day}/${widget.date.month}/${widget.date.year}';
    final timeStr = widget.time.format(context);

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
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Booking Summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _row(Icons.ev_station, 'Charger', widget.charger.name),
                  const Divider(),
                  _row(Icons.location_on, 'Location', widget.charger.address),
                  const Divider(),
                  _row(Icons.person, 'Owner', widget.charger.ownerName),
                  const Divider(),
                  _row(Icons.bolt, 'Power', '${widget.charger.powerKw} kW (${widget.charger.chargerType})'),
                  const Divider(),
                  _row(Icons.calendar_today, 'Date', dateStr),
                  const Divider(),
                  _row(Icons.access_time, 'Time', timeStr),
                  const Divider(),
                  _row(Icons.timer, 'Duration', '${widget.durationHours}h'),
                  const Divider(),
                  _row(Icons.electric_bolt, 'Est. kWh', '${widget.estimatedKwh.toStringAsFixed(1)} kWh'),
                  const Divider(),
                  _row(Icons.receipt, 'Charging cost',
                      'Rs. ${widget.totalPrice.toStringAsFixed(0)}'),
                  _row(Icons.account_balance, 'Platform fee (5%)',
                      'Rs. ${_platformFee.toStringAsFixed(0)}'),
                  const Divider(),
                  _row(Icons.payment, 'Total',
                      'Rs. ${_grandTotal.toStringAsFixed(0)}',
                      isTotal: true),
                ]),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isBooking
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isBooking ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _row(IconData icon, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF1E3A5F), size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: TextStyle(
          fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          fontSize: isTotal ? 16 : 14,
          color: isTotal ? const Color(0xFF1E3A5F) : Colors.black,
        )),
      ]),
    );
  }
}