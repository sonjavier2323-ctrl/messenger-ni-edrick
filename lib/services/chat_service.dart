import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/peer.dart';
import 'peer_service.dart';
import 'storage_service.dart';

class ChatService with ChangeNotifier {
  ChatService();

  final Map<String, List<Message>> _messages = {};
  Map<String, List<Message>> get messages => Map.unmodifiable(_messages);

  String? _currentChatPeerId;
  String? get currentChatPeerId => _currentChatPeerId;

  StreamSubscription? _peerServiceSubscription;

  void init() {
    // Initialize chat service
    _loadAllMessages();
  }

  void _onPeerServiceUpdate() {
    // Handle peer service updates if needed
  }

  Future<void> _loadAllMessages() async {
    try {
      final allMessages = await StorageService.getAllMessages();
      
      for (final message in allMessages) {
        final chatId = _getChatId(message.senderId, message.receiverId);
        
        if (!_messages.containsKey(chatId)) {
          _messages[chatId] = [];
        }
        _messages[chatId]!.add(message);
      }
      
      // Sort messages by timestamp
      for (final chatMessages in _messages.values) {
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void setPeerService(PeerService peerService) {
    _peerService = peerService;
  }

  PeerService? _peerService;

  List<Message> getMessagesForPeer(String peerId) {
    final currentPeerId = _peerService?.currentPeer?.id;
    if (currentPeerId == null) return [];
    
    final chatId = _getChatId(currentPeerId, peerId);
    return _messages[chatId] ?? [];
  }

  String _getChatId(String peer1Id, String peer2Id) {
    final ids = [peer1Id, peer2Id];
    ids.sort();
    return ids.join('_');
  }

  void setCurrentChatPeer(String peerId) {
    _currentChatPeerId = peerId;
    notifyListeners();
  }

  Future<void> sendMessage(String peerId, String content) async {
    final currentPeer = _peerService?.currentPeer;
    if (currentPeer == null) return;

    final message = Message(
      id: const Uuid().v4(),
      senderId: currentPeer.id,
      receiverId: peerId,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    final chatId = _getChatId(currentPeer.id, peerId);
    
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
    
    notifyListeners();

    try {
      // Send message via peer service (works for both auto-discovered and manual connections)
      await _peerService?.sendMessageToPeer(peerId, content);
      
      // Update message status to sent
      final updatedMessage = message.copyWith(status: MessageStatus.sent);
      _messages[chatId]![_messages[chatId]!.length - 1] = updatedMessage;
      
      // Save to storage
      await StorageService.saveMessage(updatedMessage);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending message: $e');
      
      // Update message status to failed
      final failedMessage = message.copyWith(status: MessageStatus.failed);
      _messages[chatId]![_messages[chatId]!.length - 1] = failedMessage;
      
      notifyListeners();
    }
  }

  Future<void> receiveMessage(String senderId, String content) async {
    final currentPeer = _peerService?.currentPeer;
    if (currentPeer == null) return;

    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: currentPeer.id,
      content: content,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    );

    final chatId = _getChatId(senderId, currentPeer.id);
    
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
    
    // Save to storage
    await StorageService.saveMessage(message);
    
    notifyListeners();
  }

  Future<void> markMessageAsRead(String messageId) async {
    // Find and update message status
    for (final chatMessages in _messages.values) {
      for (int i = 0; i < chatMessages.length; i++) {
        if (chatMessages[i].id == messageId) {
          final updatedMessage = chatMessages[i].copyWith(status: MessageStatus.read);
          chatMessages[i] = updatedMessage;
          
          await StorageService.updateMessageStatus(messageId, MessageStatus.read);
          notifyListeners();
          return;
        }
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    for (final chatMessages in _messages.values) {
      chatMessages.removeWhere((message) => message.id == messageId);
    }
    
    await StorageService.deleteMessage(messageId);
    notifyListeners();
  }

  Future<void> clearChat(String peerId) async {
    final currentPeerId = _peerService?.currentPeer?.id;
    if (currentPeerId == null) return;
    
    final chatId = _getChatId(currentPeerId, peerId);
    _messages.remove(chatId);
    
    await StorageService.deleteChatMessages(currentPeerId, peerId);
    notifyListeners();
  }

  int getUnreadMessageCount(String peerId) {
    final currentPeerId = _peerService?.currentPeer?.id;
    if (currentPeerId == null) return 0;
    
    final chatId = _getChatId(currentPeerId, peerId);
    final chatMessages = _messages[chatId] ?? [];
    
    return chatMessages.where((message) => 
      message.senderId == peerId && message.status != MessageStatus.read
    ).length;
  }

  Message? getLastMessage(String peerId) {
    final messages = getMessagesForPeer(peerId);
    return messages.isNotEmpty ? messages.last : null;
  }

  @override
  void dispose() {
    _peerServiceSubscription?.cancel();
    super.dispose();
  }
}
