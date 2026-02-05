import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/peer.dart';
import '../models/message.dart';

class ChatTile extends StatelessWidget {
  final Peer peer;
  final Message? lastMessage;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.peer,
    this.lastMessage,
    this.unreadCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String lastMessageText = 'No messages yet';
    String lastMessageTime = '';

    if (lastMessage != null) {
      lastMessageText = lastMessage!.content;
      lastMessageTime = _formatTime(lastMessage!.timestamp);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        peer.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMessageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unreadCount > 0 ? Colors.black87 : Colors.grey,
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (lastMessageTime.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              lastMessageTime,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
      trailing: unreadCount > 0
          ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
