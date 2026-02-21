import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/home_screen_module/model/chat_model.dart';
import 'package:mcd/core/services/ai_assistant_service.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'dart:developer' as dev;
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class AssistantScreenController extends GetxController {
  final messageController = TextEditingController();
  final AiAssistantService _aiService = AiAssistantService();
  final _box = GetStorage();

  final _chatMessages = <ChatMessage>[].obs;
  List<ChatMessage> get chatMessages => _chatMessages;

  final _isTyping = false.obs;
  bool get isTyping => _isTyping.value;

  final _connectionStatus = 'Disconnected'.obs;
  String get connectionStatus => _connectionStatus.value;

  final _isThinking = false.obs;
  bool get isThinking => _isThinking.value;

  final _isLoadingHistory = false.obs;
  bool get isLoadingHistory => _isLoadingHistory.value;

  // chat limit tracking
  final _chatLimitUsed = 0.obs;
  int get chatLimitUsed => _chatLimitUsed.value;

  final _chatLimitMax = 0.obs;
  int get chatLimitMax => _chatLimitMax.value;

  String _currentStreamResponse = '';

  @override
  void onInit() {
    super.onInit();
    // load saved limits
    _chatLimitUsed.value = _box.read('chat_limit_used') ?? 0;
    _chatLimitMax.value = _box.read('chat_limit_max') ?? 0;

    _initializeAiService();
  }

  void _initializeAiService() {
    _aiService.initSocket();

    _aiService.onStatusChange = (status) {
      _connectionStatus.value = status;
      if (status.toString().contains('processing')) {
        _isThinking.value = true;
        _isTyping.value = false;
      } else if (status.toString().contains('idle')) {
        _isThinking.value = false;
        _isTyping.value = false;
      }
    };

    _aiService.onResponse = (data) {
      _isThinking.value = false;
      _isTyping.value = false;

      if (_currentStreamResponse.isNotEmpty) {
        _finalizeStreamMessage();
      } else {
        String? messageText;
        if (data is Map && data.containsKey('content')) {
          messageText = data['content'];
        } else if (data is Map && data.containsKey('message')) {
          messageText = data['message'];
        } else {
          messageText = data.toString();
        }

        if (messageText != null) {
          _addBotMessage(messageText);
        }
      }
    };

    _aiService.onError = (error) {
      _isTyping.value = false;
      _isLoadingHistory.value = false;
      Get.snackbar(
        'Error',
        error.toString(),
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    };

    _aiService.onChatStream = (chunk) {
      _isTyping.value = true;
      _currentStreamResponse += chunk;
      _updateStreamingMessage(_currentStreamResponse);
    };

    _aiService.onHistory = (history) {
      _isLoadingHistory.value = true;
      dev.log('Loading ${history.length} messages from history',
          name: 'AiAssistant');

      _chatMessages.clear();

      for (var msg in history.reversed) {
        if (msg is Map) {
          final role = msg['role']?.toString() ?? '';
          final content =
              msg['content']?.toString() ?? msg['message']?.toString() ?? '';

          // Parse timestamp from message data if available
          DateTime? messageTimestamp;
          if (msg['timestamp'] != null) {
            try {
              messageTimestamp = DateTime.parse(msg['timestamp'].toString());
              dev.log('Parsed timestamp: $messageTimestamp from field "timestamp"', name: 'AiAssistant');
            } catch (e) {
              dev.log('Error parsing timestamp: $e', name: 'AiAssistant');
            }
          } else if (msg['createdAt'] != null) {
            try {
              messageTimestamp = DateTime.parse(msg['createdAt'].toString());
              dev.log('Parsed timestamp: $messageTimestamp from field "createdAt"', name: 'AiAssistant');
            } catch (e) {
              dev.log('Error parsing createdAt: $e', name: 'AiAssistant');
            }
          } else if (msg['created_at'] != null) {
            try {
              messageTimestamp = DateTime.parse(msg['created_at'].toString());
              dev.log('Parsed timestamp: $messageTimestamp from field "created_at"', name: 'AiAssistant');
            } catch (e) {
              dev.log('Error parsing created_at: $e', name: 'AiAssistant');
            }
          } else {
            dev.log('No timestamp field found in message: ${msg.keys}', name: 'AiAssistant');
          }

          if (content.isNotEmpty) {
            _chatMessages.add(ChatMessage(
              text: content,
              timestamp: messageTimestamp ?? DateTime.now(),
              isAi: role == 'assistant' || role == 'ai',
            ));
          }
        }
      }

      dev.log('Loaded ${_chatMessages.length} messages into chat',
          name: 'AiAssistant');
      _isLoadingHistory.value = false;
    };

    _aiService.onChatLimit = (data) {
      _isThinking.value = false;
      _isTyping.value = false;

      // parse limit data
      if (data is Map) {
        int remaining = -1;
        if (data.containsKey('remaining')) {
          remaining = int.tryParse(data['remaining'].toString()) ?? -1;
        }

        if (data.containsKey('limit') || data.containsKey('max')) {
          _chatLimitMax.value =
              int.tryParse((data['limit'] ?? data['max']).toString()) ?? 0;
        }

        // If we have remaining and max, calculate used
        if (remaining != -1 && _chatLimitMax.value > 0) {
          _chatLimitUsed.value = _chatLimitMax.value - remaining;
        } else if (data.containsKey('used')) {
          // Fallback if 'used' is explicitly provided
          _chatLimitUsed.value = int.tryParse(data['used'].toString()) ?? 0;
        }

        // save limits
        _box.write('chat_limit_used', _chatLimitUsed.value);
        _box.write('chat_limit_max', _chatLimitMax.value);
      }

      // Only show snackbar if we have reached the limit
      if (_chatLimitUsed.value >= _chatLimitMax.value &&
          _chatLimitMax.value > 0) {
        String message = 'You have reached your chat limit.';
        if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        } else if (data is String) {
          message = data;
        }

        Get.snackbar(
          'Chat Limit Reached',
          message,
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
        );
      }
    };
  }

  @override
  void onClose() {
    messageController.dispose();
    _aiService.dispose();
    super.onClose();
  }

  void addMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    _chatMessages.insert(
      0,
      ChatMessage(
        text: text,
        timestamp: DateTime.now(),
      ),
    );

    messageController.clear();
    _isTyping.value = true;
    _currentStreamResponse = '';

    _aiService.sendMessage(text);
  }

  void _addBotMessage(String text) {
    _chatMessages.insert(
      0,
      ChatMessage(
        text: text,
        timestamp: DateTime.now(),
        isAi: true,
      ),
    );
  }

  void _updateStreamingMessage(String text) {
    if (_chatMessages.isNotEmpty && _chatMessages.first.isAi) {
      _chatMessages[0] = ChatMessage(
        text: text,
        timestamp: _chatMessages.first.timestamp,
        isAi: true,
      );
      _chatMessages.refresh();
    } else {
      _chatMessages.insert(
        0,
        ChatMessage(
          text: text,
          timestamp: DateTime.now(),
          isAi: true,
        ),
      );
    }
  }

  void _finalizeStreamMessage() {
    _currentStreamResponse = '';
  }
}
