import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import 'confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final ChargerModel charger;
  const BookingScreen({super.key, required this.charger});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _durationHours = 1.0;

  // kWh calculation: powerKw × hours
  double get _estimatedKwh => widget.charger.powerKw * _durationHours;
  double get _totalPrice => _estimatedKwh * widget.charger.pricePerKwh;
  double get _platformFee => _totalPrice * 0.05;
  double get _grandTotal => _totalPrice + _platformFee;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Charger'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charger info card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.ev_station, color: Color(0xFF1E3A5F), size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: Text(widget.charger.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height: 8),
                  Text(widget.charger.address, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 16),
                    Text(' ${widget.charger.powerKw} kW • ${widget.charger.chargerType}'),
                    const SizedBox(width: 16),
                    Text('Rs. ${widget.charger.pricePerKwh.toInt()}/kWh',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Date
            const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF1E3A5F)),
                  const SizedBox(width: 12),
                  Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Time
            const Text('Select Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time, color: Color(0xFF1E3A5F)),
                  const SizedBox(width: 12),
                  Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            const Text('Duration (Hours)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                  onPressed: _durationHours > 0.5 ? () => setState(() => _durationHours -= 0.5) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFF1E3A5F),
                ),
                Text('${_durationHours}h', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _durationHours < 8 ? () => setState(() => _durationHours += 0.5) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF1E3A5F),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Cost breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                _costRow('Power', '${widget.charger.powerKw} kW × ${_durationHours}h'),
                _costRow('Estimated kWh', '${_estimatedKwh.toStringAsFixed(1)} kWh'),
                _costRow('Rate', 'Rs. ${widget.charger.pricePerKwh.toInt()}/kWh'),
                _costRow('Charging cost', 'Rs. ${_totalPrice.toStringAsFixed(0)}'),
                _costRow('Platform fee (5%)', 'Rs. ${_platformFee.toStringAsFixed(0)}'),
                const Divider(),
                _costRow('Total', 'Rs. ${_grandTotal.toStringAsFixed(0)}', isTotal: true),
              ]),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ConfirmationScreen(
                    charger: widget.charger,
                    date: _selectedDate,
                    time: _selectedTime,
                    durationHours: _durationHours,        // ✅ double
                    estimatedKwh: _estimatedKwh,           // ✅ pass kWh
                    totalPrice: _grandTotal,
                  ),
                )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed to Confirm', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _costRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFF1E3A5F) : Colors.black87)),
      ]),
    );
  }
}