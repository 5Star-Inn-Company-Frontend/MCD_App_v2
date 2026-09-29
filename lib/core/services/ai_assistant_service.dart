import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:mcd/core/services/remote_config_service.dart';
import 'dart:developer' as dev;

class AiAssistantService {
  late IO.Socket socket;
  final box = GetStorage();

  // Callbacks for UI updates
  Function(String)? onStatusChange;
  Function(dynamic)? onResponse;
  Function(dynamic)? onError;
  Function()? onDisconnect;
  Function(String)? onChatStream;
  Function(List<dynamic>)? onHistory;
  Function(dynamic)? onChatLimit;

  static const String serverUrl = 'https://mcdai.5starcompany.com.ng';

  void initSocket() {
    final token = box.read('token');

    if (token == null) {
      dev.log('No token found for AI Assistant socket connection',
          name: 'AiAssistant');
      return;
    }

    String url = serverUrl;
    if (Get.isRegistered<RemoteConfigService>()) {
      url = RemoteConfigService.to.getString('ai_assistant_server_url', defaultValue: serverUrl);
    }

    try {
      socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      _setupListeners();

      socket.connect();
    } catch (e) {
      dev.log('Error initializing socket: $e', name: 'AiAssistant');
    }
  }

  void _setupListeners() {
    socket.onConnect((_) {
      dev.log('Connected to AI Assistant Server', name: 'AiAssistant');
      onStatusChange?.call('Connected');
    });

    socket.onDisconnect((_) {
      dev.log('Disconnected from AI Assistant Server', name: 'AiAssistant');
      onStatusChange?.call('Disconnected');
      onDisconnect?.call();
    });

    socket.on('status', (data) {
      dev.log('Status: $data', name: 'AiAssistant');
      onStatusChange?.call(data.toString());
    });

    socket.on('response', (data) {
      dev.log('Response: $data', name: 'AiAssistant');
      onResponse?.call(data);
    });

    socket.on('error', (data) {
      dev.log('Error from server: $data', name: 'AiAssistant');
      onError?.call(data);
    });

    socket.on('chat-stream', (data) {
      // dev.log('Chat StreamChunk received', name: 'AiAssistant'); // Commented out to avoid log spam
      if (data != null) {
        // Parse chunk from data: {chunk: "text"}
        String chunkText;
        if (data is Map && data.containsKey('chunk')) {
          chunkText = data['chunk'].toString();
        } else {
          chunkText = data.toString();
        }
        onChatStream?.call(chunkText);
      }
    });

    socket.on('history', (data) {
      dev.log('History received: ${data.length} messages', name: 'AiAssistant');
      if (data is List) {
        onHistory?.call(data);
      }
    });

    socket.on('chat-limit', (data) {
      dev.log('Chat limit reached: $data', name: 'AiAssistant');
      onChatLimit?.call(data);
    });
  }

  void sendMessage(String message) {
    if (socket.connected) {
      socket.emit('chat', {'message': message});
    } else {
      dev.log('Cannot send message: Socket not connected', name: 'AiAssistant');
      onError?.call('Connection lost. Reconnecting...');
    }
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
