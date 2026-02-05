import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import '../models/message.dart';

class StorageService {
  static Database? _database;

  static Future<void> init() async {
    if (kIsWeb) {
      // Web doesn't support SQLite, use mock implementation
      return;
    }
    
    // Initialize FFI for desktop
    if (!kIsWeb) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'messenger.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            sender_id TEXT NOT NULL,
            receiver_id TEXT NOT NULL,
            content TEXT NOT NULL,
            type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> saveMessage(Message message) async {
    if (kIsWeb) {
      // Web mock implementation - store in memory
      return;
    }
    
    if (_database == null) await init();

    await _database!.insert(
      'messages',
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Message>> getAllMessages() async {
    if (kIsWeb) {
      // Web mock implementation - return empty list
      return [];
    }
    
    if (_database == null) await init();

    final List<Map<String, dynamic>> maps = await _database!.query('messages');

    return List.generate(maps.length, (i) {
      return Message.fromJson(maps[i]);
    });
  }

  static Future<List<Message>> getMessagesForPeer(String userId, String peerId) async {
    if (kIsWeb) {
      // Web mock implementation - return empty list
      return [];
    }
    
    if (_database == null) await init();

    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
      SELECT * FROM messages 
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
      ORDER BY timestamp ASC
    ''', [userId, peerId, peerId, userId]);

    return List.generate(maps.length, (i) {
      return Message.fromJson(maps[i]);
    });
  }

  static Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    if (kIsWeb) {
      // Web mock implementation
      return;
    }
    
    if (_database == null) await init();

    await _database!.update(
      'messages',
      {'status': status.toString()},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  static Future<void> deleteMessage(String messageId) async {
    if (kIsWeb) {
      // Web mock implementation
      return;
    }
    
    if (_database == null) await init();

    await _database!.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  static Future<void> deleteChatMessages(String userId, String peerId) async {
    if (kIsWeb) {
      // Web mock implementation
      return;
    }
    
    if (_database == null) await init();

    await _database!.rawDelete('''
      DELETE FROM messages 
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
    ''', [userId, peerId, peerId, userId]);
  }

  static Future<void> clearAllMessages() async {
    if (kIsWeb) {
      // Web mock implementation
      return;
    }
    
    if (_database == null) await init();

    await _database!.delete('messages');
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
