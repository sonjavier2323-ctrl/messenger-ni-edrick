import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/peer_service.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';
import '../screens/manual_connection_screen.dart';
import '../widgets/peer_tile.dart';

class PeerListScreen extends StatelessWidget {
  const PeerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Peers'),
        actions: [
          Consumer<PeerService>(
            builder: (context, peerService, child) {
              return IconButton(
                icon: Icon(
                  peerService.isDiscovering ? Icons.stop : Icons.play_arrow,
                ),
                onPressed: () {
                  if (peerService.isDiscovering) {
                    peerService.stopDiscovery();
                  } else {
                    peerService.startDiscovery();
                  }
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManualConnectionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_link),
        tooltip: 'Manual IP Connection',
      ),
      body: Consumer<PeerService>(
        builder: (context, peerService, child) {
          if (peerService.isDiscovering && peerService.peers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Discovering peers...'),
                ],
              ),
            );
          }

          if (peerService.peers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No peers found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Make sure other devices are on the same WiFi network',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh peer list
            },
            child: ListView.builder(
              itemCount: peerService.peers.length,
              itemBuilder: (context, index) {
                final peer = peerService.peers[index];
                return PeerTile(
                  peer: peer,
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
            ),
          );
        },
      ),
    );
  }
}
