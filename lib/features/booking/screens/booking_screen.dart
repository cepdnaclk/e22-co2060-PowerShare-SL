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

  // Duration in minutes for precision
  int _durationMinutes = 60;

  static const Color _primary = Color(0xFF1E3A5F);

  // ── Calculated values ──────────────────────────────────────────
  double get _durationHours => _durationMinutes / 60.0;
  double get _estimatedKwh => widget.charger.powerKw * _durationHours;
  double get _totalPrice => _estimatedKwh * widget.charger.pricePerKwh;
  double get _platformFee => _totalPrice * 0.05; // 5% platform fee
  double get _grandTotal => _totalPrice + _platformFee;

  String get _durationLabel {
    final h = _durationMinutes ~/ 60;
    final m = _durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}hr';
    return '${h}hr ${m}min';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _changeDuration(int deltaMinutes) {
    setState(() {
      _durationMinutes = (_durationMinutes + deltaMinutes).clamp(30, 480);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Charger'),
        backgroundColor: _primary,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.ev_station,
                            color: _primary, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.charger.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.charger.address,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.bolt,
                            color: Colors.amber, size: 16),
                        Text(' ${widget.charger.powerKw} kW'),
                        const SizedBox(width: 16),
                        const Icon(Icons.attach_money,
                            color: Colors.green, size: 16),
                        Text(
                            ' Rs. ${widget.charger.pricePerKwh.toStringAsFixed(0)}/kWh'),
                        const SizedBox(width: 16),
                        const Icon(Icons.star,
                            color: Colors.amber, size: 16),
                        Text(' ${widget.charger.rating}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Estimated cost per hour chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '≈ Rs. ${widget.charger.estimatedCostPerHour.toStringAsFixed(0)}/hr estimated',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date picker
            const Text('Select Date',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: _primary),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time picker
            const Text('Select Start Time',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: _primary),
                    const SizedBox(width: 12),
                    Text(_selectedTime.format(context),
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Duration selector — minute-level precision
            const Text('Charging Duration',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Decrease buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _changeDuration(-60),
                            child: const Text('-1hr',
                                style: TextStyle(color: _primary)),
                          ),
                          TextButton(
                            onPressed: () => _changeDuration(-30),
                            child: const Text('-30m',
                                style: TextStyle(color: _primary)),
                          ),
                        ],
                      ),
                      Text(
                        _durationLabel,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _primary),
                      ),
                      // Increase buttons
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _changeDuration(30),
                            child: const Text('+30m',
                                style: TextStyle(color: _primary)),
                          ),
                          TextButton(
                            onPressed: () => _changeDuration(60),
                            child: const Text('+1hr',
                                style: TextStyle(color: _primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Duration slider
                  Slider(
                    value: _durationMinutes.toDouble(),
                    min: 30,
                    max: 480,
                    divisions: 15, // 30-min steps
                    activeColor: _primary,
                    label: _durationLabel,
                    onChanged: (val) =>
                        setState(() => _durationMinutes = val.round()),
                  ),
                  Text(
                    'Min: 30min  •  Max: 8hrs',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accurate cost breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.05),
                border: Border.all(color: _primary.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cost Breakdown',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  _row('Charger Power', '${widget.charger.powerKw} kW'),
                  _row('Duration', _durationLabel),
                  _row('Estimated Energy',
                      '${_estimatedKwh.toStringAsFixed(2)} kWh'),
                  _row('Rate',
                      'Rs. ${widget.charger.pricePerKwh.toStringAsFixed(0)}/kWh'),
                  _row('Charging Cost',
                      'Rs. ${_totalPrice.toStringAsFixed(2)}'),
                  _row('Platform Fee (5%)',
                      'Rs. ${_platformFee.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payable',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(
                        'Rs. ${_grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.orange),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Final cost is based on actual kWh consumed. Estimate shown here.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Proceed button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmationScreen(
                        charger: widget.charger,
                        date: _selectedDate,
                        time: _selectedTime,
                        durationHours: _durationHours,
                        totalPrice: _grandTotal,
                        estimatedKwh: _estimatedKwh,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed to Confirm',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ],
        ),
      );
}