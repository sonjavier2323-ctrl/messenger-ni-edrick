import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../models/peer.dart';

class PeerService with ChangeNotifier {
  PeerService() {
    _initializePeer();
    _requestPermissions();
  }

  List<Peer> _peers = [];
  List<Peer> get peers => _peers;

  Peer? _currentPeer;
  Peer? get currentPeer => _currentPeer;

  bool _isDiscovering = false;
  bool get isDiscovering => _isDiscovering;

  bool _isServerRunning = false;
  bool get isServerRunning => _isServerRunning;

  ServerSocket? _server;
  final List<Socket> _clients = [];
  final Map<String, Socket> _peerConnections = {};

  Timer? _discoveryTimer;
  Timer? _heartbeatTimer;

  static Future<void> init() async {
    // Static init removed - services are now created via Provider
  }

  Future<void> _initializePeer() async {
    final info = await NetworkInfo().getWifiIP();
    final deviceName = Platform.localHostname;
    
    _currentPeer = Peer(
      id: const Uuid().v4(),
      name: deviceName,
      ipAddress: info ?? '127.0.0.1',
      port: 8080,
      lastSeen: DateTime.now(),
    );
    
    notifyListeners();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.nearbyWifiDevices.request();
    await Permission.storage.request();
  }

  Future<void> startDiscovery() async {
    if (_isDiscovering) return;

    _isDiscovering = true;
    notifyListeners();

    try {
      await _startServer();
      _startPeerDiscovery();
      _startHeartbeat();
    } catch (e) {
      debugPrint('Error starting discovery: $e');
      _isDiscovering = false;
      notifyListeners();
    }
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    _isDiscovering = false;
    _discoveryTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    await _stopServer();
    
    notifyListeners();
  }

  Future<void> _startServer() async {
    try {
      _server = await ServerSocket.bind('0.0.0.0', 8080);
      _isServerRunning = true;
      
      _server!.listen((Socket client) {
        _handleClientConnection(client);
      });
      
      debugPrint('Server started on port 8080');
    } catch (e) {
      debugPrint('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> _stopServer() async {
    for (final client in _clients) {
      client.close();
    }
    _clients.clear();
    _peerConnections.clear();
    
    await _server?.close();
    _server = null;
    _isServerRunning = false;
    
    debugPrint('Server stopped');
  }

  void _handleClientConnection(Socket client) {
    _clients.add(client);
    
    client.listen(
      (data) {
        _handleIncomingData(client, data);
      },
      onDone: () {
        _clients.remove(client);
        _removePeerConnection(client);
      },
      onError: (error) {
        debugPrint('Client error: $error');
        _clients.remove(client);
        _removePeerConnection(client);
      },
    );
  }

  void _handleIncomingData(Socket client, List<int> data) {
    try {
      final message = String.fromCharCodes(data);
      debugPrint('Received: $message');
      
      // Parse peer discovery messages
      if (message.startsWith('PEER_DISCOVERY:')) {
        _handlePeerDiscovery(client, message);
      }
    } catch (e) {
      debugPrint('Error handling incoming data: $e');
    }
  }

  void _handlePeerDiscovery(Socket client, String message) {
    try {
      final parts = message.split(':');
      if (parts.length >= 4) {
        final peerId = parts[1];
        final peerName = parts[2];
        final peerIp = client.remoteAddress.address;
        
        final peer = Peer(
          id: peerId,
          name: peerName,
          ipAddress: peerIp,
          port: 8080,
          lastSeen: DateTime.now(),
        );
        
        _addOrUpdatePeer(peer);
        
        // Send response
        client.write('PEER_RESPONSE:${_currentPeer!.id}:${_currentPeer!.name}');
      }
    } catch (e) {
      debugPrint('Error handling peer discovery: $e');
    }
  }

  void _addOrUpdatePeer(Peer peer) {
    final existingIndex = _peers.indexWhere((p) => p.id == peer.id);
    
    if (existingIndex >= 0) {
      _peers[existingIndex] = _peers[existingIndex].copyWith(
        lastSeen: DateTime.now(),
      );
    } else {
      _peers.add(peer);
    }
    
    notifyListeners();
  }

  void _startPeerDiscovery() {
    _discoveryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _broadcastDiscovery();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _cleanupOldPeers();
    });
  }

  Future<void> _broadcastDiscovery() async {
    try {
      final wifiIP = await NetworkInfo().getWifiIP();
      if (wifiIP == null) return;

      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
      
      for (int i = 1; i <= 254; i++) {
        final targetIP = '$subnet.$i';
        if (targetIP != wifiIP) {
          _sendDiscoveryMessage(targetIP);
        }
      }
    } catch (e) {
      debugPrint('Error broadcasting discovery: $e');
    }
  }

  Future<void> _sendDiscoveryMessage(String targetIP) async {
    try {
      final socket = await Socket.connect(targetIP, 8080, 
          timeout: const Duration(milliseconds: 500));
      
      final message = 'PEER_DISCOVERY:${_currentPeer!.id}:${_currentPeer!.name}';
      socket.write(message);
      
      socket.close();
    } catch (e) {
      // Expected - most IPs won't have our app running
    }
  }

  void _cleanupOldPeers() {
    final now = DateTime.now();
    _peers.removeWhere((peer) {
      final age = now.difference(peer.lastSeen);
      return age.inSeconds > 30; // Remove peers not seen for 30 seconds
    });
    
    notifyListeners();
  }

  void _removePeerConnection(Socket client) {
    _peerConnections.removeWhere((key, value) => value == client);
  }

  Future<void> connectToIP(String ipAddress, {int port = 8080}) async {
    try {
      final socket = await Socket.connect(ipAddress, port);
      
      // Create a temporary peer for this connection
      final tempPeer = Peer(
        id: ipAddress, // Use IP as ID for manual connections
        name: 'Manual ($ipAddress)',
        ipAddress: ipAddress,
        port: port,
        lastSeen: DateTime.now(),
      );
      
      _peerConnections[ipAddress] = socket;
      _addOrUpdatePeer(tempPeer);
      
      socket.listen(
        (data) => _handleIncomingData(socket, data),
        onDone: () => _peerConnections.remove(ipAddress),
        onError: (error) => _peerConnections.remove(ipAddress),
      );
      
      debugPrint('Connected to IP: $ipAddress:$port');
    } catch (e) {
      debugPrint('Failed to connect to IP $ipAddress:$port - $e');
      rethrow;
    }
  }

  Future<void> connectToPeer(Peer peer) async {
    try {
      final socket = await Socket.connect(peer.ipAddress, peer.port);
      _peerConnections[peer.id] = socket;
      
      socket.listen(
        (data) => _handleIncomingData(socket, data),
        onDone: () => _peerConnections.remove(peer.id),
        onError: (error) => _peerConnections.remove(peer.id),
      );
      
      debugPrint('Connected to peer: ${peer.name}');
    } catch (e) {
      debugPrint('Failed to connect to peer: $e');
    }
  }

  Future<void> sendMessageToPeer(String peerId, String message) async {
    final socket = _peerConnections[peerId];
    if (socket != null) {
      try {
        socket.write('MESSAGE:$message');
      } catch (e) {
        debugPrint('Error sending message: $e');
        _peerConnections.remove(peerId);
      }
    }
  }

  @override
  void dispose() {
    stopDiscovery();
    super.dispose();
  }
}
