import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class HostBookingsScreen extends StatefulWidget {
  const HostBookingsScreen({super.key});

  @override
  State<HostBookingsScreen> createState() => _HostBookingsScreenState();
}

class _HostBookingsScreenState extends State<HostBookingsScreen> {
  static const Color _primary = Color(0xFF1E3A5F);
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    final bookings = await ApiService.getReceivedBookings();
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Received Bookings'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchBookings),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F)))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Bookings නෑ', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('EV users ඔබේ charger book කළ විට මෙහි පෙනෙනවා.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: _primary,
                  onRefresh: _fetchBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      final status = b['status'] ?? 'confirmed';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      b['chargerName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E3A5F),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status[0].toUpperCase() + status.substring(1),
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Customer info
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(b['userName'] ?? '-', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.email, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      b['userEmail'] ?? '-',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Booking details
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text('${b['date']} at ${b['time']}', style: const TextStyle(fontSize: 13)),
                                  const Spacer(),
                                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${b['durationHours']}hr', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Rs. ${b['totalPrice']?.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A5F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
