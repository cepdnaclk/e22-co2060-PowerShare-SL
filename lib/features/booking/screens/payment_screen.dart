import 'package:flutter/material.dart';
import '../../../models/charger_model.dart';
import '../../../services/api_service.dart';
import '../../map/screens/map_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ChargerModel charger;
  final DateTime date;
  final TimeOfDay time;
  final double durationHours;
  final double estimatedKwh;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.charger,
    required this.date,
    required this.time,
    required this.durationHours,
    required this.estimatedKwh,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0=Card, 1=Dialog, 2=Mobitel
  bool _isProcessing = false;

  static const Color _primary = Color(0xFF1E3A5F);

  // Mock card fields
  final _cardNumber = TextEditingController(text: '4111 1111 1111 1111');
  final _cardName = TextEditingController(text: 'Test User');
  final _expiry = TextEditingController(text: '12/26');
  final _cvv = TextEditingController(text: '123');

  final List<Map<String, dynamic>> _methods = [
    {
      'label': 'Credit / Debit Card',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'label': 'Dialog Pay',
      'icon': Icons.phone_android,
      'color': Colors.orange,
    },
    {
      'label': 'Mobitel Pay',
      'icon': Icons.phone_android,
      'color': Colors.green,
    },
  ];

  String get _durationLabel {
    final totalMinutes = (widget.durationHours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}hr';
    return '${h}hr ${m}min';
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Save booking to backend
    final dateStr =
        '${widget.date.day}/${widget.date.month}/${widget.date.year}';
    final timeStr = widget.time.format(context);

    final result = await ApiService.createBooking(
      chargerId: widget.charger.id,
      chargerName: widget.charger.name,
      chargerAddress: widget.charger.address,
      date: dateStr,
      time: timeStr,
      durationHours: widget.durationHours,
      totalPrice: widget.totalPrice,
      estimatedKwh: widget.estimatedKwh,
    );

    setState(() => _isProcessing = false);
    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccess(dateStr, timeStr);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Booking failed.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showSuccess(String dateStr, String timeStr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            const Text('Payment Successful!',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Rs. ${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _summaryRow('📍', widget.charger.name),
                  _summaryRow('📅', '$dateStr  $timeStr'),
                  _summaryRow('⏱', _durationLabel),
                  _summaryRow('⚡',
                      '${widget.estimatedKwh.toStringAsFixed(2)} kWh'),
                  _summaryRow('💳',
                      _methods[_selectedMethod]['label'] as String),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MapScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back to Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String emoji, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    'Rs. ${widget.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.charger.name}  •  $_durationLabel  •  ${widget.estimatedKwh.toStringAsFixed(1)} kWh',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment method selector
            const Text('Payment Method',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ..._methods.asMap().entries.map((entry) {
              final i = entry.key;
              final method = entry.value;
              final isSelected = _selectedMethod == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (method['color'] as Color).withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? method['color'] as Color
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(method['icon'] as IconData,
                          color: isSelected
                              ? method['color'] as Color
                              : Colors.grey),
                      const SizedBox(width: 12),
                      Text(method['label'] as String,
                          style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? method['color'] as Color
                                  : Colors.black87)),
                      const Spacer(),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? method['color'] as Color
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Card details (show only for card method)
            if (_selectedMethod == 0) ...[
              const Text('Card Details',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _cardField(_cardNumber, 'Card Number',
                  Icons.credit_card),
              const SizedBox(height: 10),
              _cardField(
                  _cardName, 'Cardholder Name', Icons.person),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _cardField(
                          _expiry, 'Expiry (MM/YY)', Icons.date_range)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _cardField(
                          _cvv, 'CVV', Icons.lock,
                          obscure: true)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.blue, size: 14),
                    SizedBox(width: 6),
                    Text('Test mode — no real charge',
                        style: TextStyle(
                            fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Mobile payment info
            if (_selectedMethod > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMethod == 1
                          ? 'Dialog Pay Simulation'
                          : 'Mobitel Pay Simulation',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A payment request of Rs. ${widget.totalPrice.toStringAsFixed(2)} will be sent to your mobile number.',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text('📱 077X XXX XXXX',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Pay button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Processing Payment...',
                              style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Text(
                        'Pay Rs. ${widget.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _cardField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}