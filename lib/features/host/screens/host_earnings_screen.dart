import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class HostEarningsScreen extends StatefulWidget {
  const HostEarningsScreen({super.key});

  @override
  State<HostEarningsScreen> createState() => _HostEarningsScreenState();
}

class _HostEarningsScreenState extends State<HostEarningsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await ApiService.getHostEarnings();
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _data = result;
      } else {
        _error = result['message'] ?? 'Error loading earnings';
      }
    });
  }

  void _showWithdrawDialog() {
    final amountCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final accNoCtrl = TextEditingController();
    final accNameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: Color(0xFF1E3A5F)),
                      const SizedBox(width: 8),
                      const Text('Withdraw Earnings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: Rs. ${_data!['availableBalance'].toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontSize: 13),
                  ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Amount (Rs.)', Icons.money),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount required';
                      final amt = double.tryParse(v);
                      if (amt == null || amt < 500) return 'Minimum Rs. 500';
                      final balance = (_data!['availableBalance'] as num).toDouble();
                      if (amt > balance) return 'Exceeds available balance';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: bankCtrl,
                    decoration: _inputDeco('Bank Name', Icons.account_balance),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Bank name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accNoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('Account Number', Icons.numbers),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Account number required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: accNameCtrl,
                    decoration:
                        _inputDeco('Account Holder Name', Icons.person),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Account name required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isProcessing
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setSheetState(() => isProcessing = true);
                              final result =
                                  await ApiService.requestWithdrawal(
                                amount: double.parse(amountCtrl.text),
                                bankName: bankCtrl.text,
                                accountNumber: accNoCtrl.text,
                                accountName: accNameCtrl.text,
                              );
                              setSheetState(() => isProcessing = false);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              if (result['success'] == true) {
                                _showSuccessDialog(result);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ??
                                        'Withdrawal failed'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Submit Withdrawal Request',
                              style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Request Submitted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference: ${result['reference']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount: Rs. ${result['amount']}'),
            Text('Bank: ${result['bankName']}'),
            Text('Account: ${result['accountNumber']}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⏳ Estimated: ${result['estimatedDays']}',
                style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _loadEarnings();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A5F)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Earnings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarnings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadEarnings,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEarnings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            _summaryCard(
                              'Total Earned',
                              'Rs. ${(_data!['totalEarned'] as num).toStringAsFixed(2)}',
                              Icons.trending_up,
                              Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _summaryCard(
                              'Available',
                              'Rs. ${(_data!['availableBalance'] as num).toStringAsFixed(2)}',
                              Icons.account_balance_wallet,
                              const Color(0xFF1E3A5F),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Withdraw Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.download),
                            label: const Text('Withdraw Earnings',
                                style: TextStyle(fontSize: 16)),
                            onPressed:
                                (_data!['availableBalance'] as num) > 0
                                    ? _showWithdrawDialog
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Minimum withdrawal: Rs. 500 • 3-5 business days',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // Earnings History
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Earnings History',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),

                        if ((_data!['earningsList'] as List).isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long,
                                      size: 60, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text('No earnings yet',
                                      style: TextStyle(color: Colors.grey)),
                                  SizedBox(height: 4),
                                  Text(
                                    'Accepted bookings will appear here',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...(_data!['earningsList'] as List)
                              .map((e) => _earningCard(e))
                              ,
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(title,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _earningCard(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.ev_station,
                  color: Color(0xFF1E3A5F), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e['chargerName'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rs. ${(e['hostEarning'] as num).toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(e['chargerAddress'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoChip(Icons.calendar_today, e['date'] ?? ''),
              const SizedBox(width: 8),
              _infoChip(Icons.access_time, e['time'] ?? ''),
              const SizedBox(width: 8),
              _infoChip(Icons.timer,
                  '${e['durationHours']}h'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Driver paid: Rs. ${(e['totalPaid'] as num).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                'Fee: Rs. ${(e['platformFee'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 12, color: Colors.orange.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}