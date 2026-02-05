import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/peer_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDeviceInfo(context),
          const SizedBox(height: 24),
          _buildDiscoverySettings(context),
          const SizedBox(height: 24),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    return Consumer<PeerService>(
      builder: (context, peerService, child) {
        final currentPeer = peerService.currentPeer;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Device Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Copy IP address to clipboard
                        // TODO: Implement clipboard functionality
                      },
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy IP Address',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Device Name', currentPeer?.name ?? 'Unknown'),
                _buildInfoRow('Device ID', currentPeer?.id ?? 'Unknown'),
                _buildInfoRow('IP Address', currentPeer?.ipAddress ?? 'Unknown'),
                _buildInfoRow('Port', currentPeer?.port.toString() ?? 'Unknown'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share this IP address with others to connect directly!',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Others can connect to you using: ${currentPeer?.ipAddress ?? 'Unknown'}:8080',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverySettings(BuildContext context) {
    return Consumer<PeerService>(
      builder: (context, peerService, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discovery Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Peer Discovery'),
                  subtitle: const Text('Discover other devices on the network'),
                  value: peerService.isDiscovering,
                  onChanged: (value) {
                    if (value) {
                      peerService.startDiscovery();
                    } else {
                      peerService.stopDiscovery();
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Server Status'),
                  subtitle: Text(peerService.isServerRunning ? 'Running' : 'Stopped'),
                  value: peerService.isServerRunning,
                  onChanged: (value) {
                    // Server is controlled by discovery
                    if (!peerService.isDiscovering && value) {
                      peerService.startDiscovery();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Offline Messenger'),
            const SizedBox(height: 4),
            const Text('Version 1.0.0'),
            const SizedBox(height: 12),
            const Text(
              'A peer-to-peer messaging app that works without internet connection.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'How it works:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '• Connect to the same WiFi network\n'
              '• Enable peer discovery\n'
              '• Start chatting with nearby devices',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
