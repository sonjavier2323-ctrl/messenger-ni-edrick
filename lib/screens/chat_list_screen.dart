import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/peer_service.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';
import '../widgets/chat_tile.dart';
import '../models/peer.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<PeerService, ChatService>(
        builder: (context, peerService, chatService, child) {
          // Get unique peers from messages
          final currentPeerId = peerService.currentPeer?.id;
          if (currentPeerId == null) {
            return const Center(
              child: Text('Unable to get current peer information'),
            );
          }

          final chatPeers = <String>{};
          for (final messageList in chatService.messages.values) {
            for (final message in messageList) {
              if (message.senderId == currentPeerId) {
                chatPeers.add(message.receiverId);
              } else {
                chatPeers.add(message.senderId);
              }
            }
          }

          if (chatPeers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a conversation from the Peers tab',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatPeers.length,
            itemBuilder: (context, index) {
              final peerId = chatPeers.elementAt(index);
              final peer = peerService.peers.firstWhere(
                (p) => p.id == peerId,
                orElse: () => Peer(
                  id: peerId,
                  name: 'Unknown User',
                  ipAddress: '',
                  port: 0,
                  lastSeen: DateTime.now(),
                ),
              );

              return ChatTile(
                peer: peer,
                lastMessage: chatService.getLastMessage(peerId),
                unreadCount: chatService.getUnreadMessageCount(peerId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(peer: peer),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
