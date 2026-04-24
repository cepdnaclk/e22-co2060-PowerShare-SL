import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _primary = Color(0xFF1E3A5F);
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _fetchNotifications(); }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final notifs = await ApiService.getNotifications();
    setState(() { _notifications = notifs; _isLoading = false; });
  }

  Future<void> _markAllRead() async {
    await ApiService.markAllNotificationsRead();
    setState(() { for (var n in _notifications) n['isRead'] = true; });
  }

  Future<void> _markRead(String id, int index) async {
    await ApiService.markNotificationRead(id);
    setState(() => _notifications[index]['isRead'] = true);
  }

  IconData _icon(String type) {
    switch (type) {
      case 'booking':      return Icons.calendar_today;
      case 'confirmation': return Icons.check_circle;
      case 'cancelled':    return Icons.cancel;
      case 'earnings':     return Icons.payments;
      case 'reminder':     return Icons.alarm;
      default:             return Icons.notifications;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'booking':      return Colors.blue;
      case 'confirmation': return Colors.green;
      case 'cancelled':    return Colors.red;
      case 'earnings':     return Colors.orange;
      case 'reminder':     return Colors.purple;
      default:             return Colors.grey;
    }
  }

  String _timeAgo(String ts) {
    final dt = DateTime.tryParse(ts);
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1)  return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24)   return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => n['isRead'] == false).length;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifications'),
          if (unread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        backgroundColor: _primary, foregroundColor: Colors.white,
        actions: [
          if (unread > 0) TextButton(onPressed: _markAllRead, child: const Text('Mark all read', style: TextStyle(color: Colors.white70, fontSize: 13))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNotifications),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A5F)))
          : _notifications.isEmpty ? _buildEmpty()
          : RefreshIndicator(
              color: _primary, onRefresh: _fetchNotifications,
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (ctx, i) {
                  final n = _notifications[i];
                  final isRead = n['isRead'] == true;
                  final type = n['type'] ?? 'system';
                  return InkWell(
                    onTap: () { if (!isRead) _markRead(n['_id'], i); },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isRead ? Colors.grey.shade200 : const Color(0xFF185FA5).withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: _color(type).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Icon(_icon(type), color: _color(type), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(n['title'] ?? '', style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, color: _primary))),
                              Text(_timeAgo(n['createdAt'] ?? ''), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ]),
                            const SizedBox(height: 4),
                            Text(n['message'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                          ])),
                          if (!isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4, left: 6), decoration: const BoxDecoration(color: Color(0xFF185FA5), shape: BoxShape.circle)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFE6F1FB), borderRadius: BorderRadius.circular(60)),
      child: const Icon(Icons.notifications_none, size: 60, color: Color(0xFF185FA5))),
    const SizedBox(height: 20),
    const Text('Notifications නෑ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
    const SizedBox(height: 8),
    const Text('Bookings සහ updates මෙහි පෙනෙනවා.', style: TextStyle(color: Colors.grey)),
  ]));
}
