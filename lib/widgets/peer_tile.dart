import 'package:flutter/material.dart';
import '../models/peer.dart';

class PeerTile extends StatelessWidget {
  final Peer peer;
  final VoidCallback onTap;

  const PeerTile({
    super.key,
    required this.peer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastSeen = DateTime.now().difference(peer.lastSeen);
    String status = 'Offline';
    Color statusColor = Colors.grey;
    
    if (lastSeen.inSeconds < 10) {
      status = 'Online';
      statusColor = Colors.green;
    } else if (lastSeen.inMinutes < 1) {
      status = 'Last seen just now';
      statusColor = Colors.orange;
    } else if (lastSeen.inMinutes < 60) {
      status = 'Last seen ${lastSeen.inMinutes} min ago';
      statusColor = Colors.orange;
    } else {
      status = 'Last seen ${lastSeen.inHours} hours ago';
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor,
                statusColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Text(
          peer.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${peer.ipAddress}:${peer.port}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.chat,
            color: Color(0xFF6C63FF),
            size: 20,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
