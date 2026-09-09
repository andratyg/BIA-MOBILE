import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  final Dio _dio = ApiService.instance.dio;

  ChatProvider() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Halo! Selamat datang di Verdatica. Ada yang bisa saya bantu seputar perawatan tanamanmu hari ini?',
      isUser: false,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _dio.post(
        ApiConfig.chat,
        data: {'message': text},
      );
      final reply = response.data['reply'] as String? ?? 'Maaf, tidak ada balasan.';
      _messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Maaf, sepertinya ada gangguan koneksi ke server Verdatica.',
        isUser: false,
        isError: true,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
