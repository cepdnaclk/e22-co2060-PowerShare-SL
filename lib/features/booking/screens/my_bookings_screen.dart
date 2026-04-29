import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  static const Color _primary = Color(0xFF1E3A5F);

  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() { _isLoading = true; _error = null; });
    final bookings = await ApiService.getMyBookings();
    setState(() { _isLoading = false; _bookings = bookings; });
  }

  Future<void> _cancelBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Booking cancel කරන්නද? Refund eligible නම් auto refund වෙනවා.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.cancelBooking(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? (result['success'] == true
            ? 'Booking cancelled'
            : 'Failed to cancel')),
        backgroundColor:
            result['success'] == true ? Colors.green : Colors.red,
      ));
      if (result['success'] == true) _fetchBookings();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':            return Colors.green;
      case 'pending_confirmation': return Colors.orange;
      case 'pending':              return Colors.orange;
      case 'rejected':             return Colors.red;
      case 'cancelled':            return Colors.red;
      case 'completed':            return Colors.blue;
      default:                     return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':            return Icons.check_circle;
      case 'pending_confirmation': return Icons.hourglass_top;
      case 'pending':              return Icons.pending;
      case 'rejected':             return Icons.cancel;
      case 'cancelled':            return Icons.cancel;
      case 'completed':            return Icons.verified;
      default:                     return Icons.info;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_confirmation': return 'Awaiting Host';
      case 'confirmed':            return 'Confirmed';
      case 'rejected':             return 'Rejected';
      case 'cancelled':            return 'Cancelled';
      case 'completed':            return 'Completed';
      default:                     return status[0].toUpperCase() + status.substring(1);
    }
  }

  Color _paymentColor(String? ps) {
    switch (ps) {
      case 'released': return Colors.green;
      case 'refunded': return Colors.blue;
      case 'held':     return Colors.orange;
      default:         return Colors.grey;
    }
  }

  String _paymentLabel(String? ps) {
    switch (ps) {
      case 'released': return '💰 Payment Released';
      case 'refunded': return '↩️ Refunded';
      case 'held':     return '🔒 Payment Held';
      default:         return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _fetchBookings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F)))
          : _bookings.isEmpty
              ? _buildEmpty()
              : _buildList(),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.event_note,
                  size: 64, color: Color(0xFF185FA5)),
            ),
            const SizedBox(height: 24),
            const Text('No bookings yet!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F))),
            const SizedBox(height: 8),
            const Text('Tap a Map charger and do your first booking',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.map),
              label: const Text('Go to Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: _primary,
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final b = _bookings[index];
          final status = b['status'] ?? 'pending_confirmation';
          final paymentStatus = b['paymentStatus'] as String?;
          return _buildCard(b, status, paymentStatus);
        },
      ),
    );
  }

  Widget _buildCard(dynamic b, String status, String? paymentStatus) {
    final canCancel = status == 'pending_confirmation' || status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.ev_station,
                    color: Color(0xFF1E3A5F), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    b['chargerName'] ?? 'Unknown Charger',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1E3A5F)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status),
                          size: 12, color: _statusColor(status)),
                      const SizedBox(width: 4),
                      Text(_statusLabel(status),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(status))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.location_on, 'Location',
                    b['chargerAddress'] ?? '-'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _detailRow(Icons.calendar_today, 'Date',
                            b['date'] ?? '-')),
                    Expanded(
                        child: _detailRow(
                            Icons.access_time, 'Time', b['time'] ?? '-')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _detailRow(Icons.timer, 'Duration',
                          '${b['durationHours'] ?? 1}hr'),
                    ),
                    Expanded(
                      child: _detailRow(
                        Icons.bolt, 'Est. kWh',
                        '${(b['estimatedKwh'] ?? 0).toStringAsFixed(1)} kWh',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _detailRow(
                        Icons.payments, 'Total',
                        'Rs. ${b['totalPrice']?.toStringAsFixed(2) ?? '0'}',
                        valueColor: _primary,
                        valueBold: true,
                      ),
                    ),
                    // Payment status chip
                    if (paymentStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _paymentColor(paymentStatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _paymentLabel(paymentStatus),
                          style: TextStyle(
                              fontSize: 11,
                              color: _paymentColor(paymentStatus),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),

                // Rejected/Refund note
                if (status == 'rejected') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue, size: 14),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Host rejected this booking. Your payment has been refunded.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Awaiting host note
                if (status == 'pending_confirmation') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_top,
                            color: Colors.orange, size: 14),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Waiting for host to confirm. Payment is held securely.',
                            style: TextStyle(
                                fontSize: 11, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Cancel button
          if (canCancel)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
              ),
              child: TextButton.icon(
                onPressed: () => _cancelBooking(b['_id']),
                icon: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 18),
                label: const Text('Cancel Booking',
                    style: TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        valueBold ? FontWeight.bold : FontWeight.normal,
                    color: valueColor ?? Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}