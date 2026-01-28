import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service for interacting with GitHub Models API (GPT-4o-mini)
class GeminiService {
  static const String _apiKey = AppConfig.githubModelsApiKey;
  static const String _baseUrl = 'https://models.github.ai/inference/chat/completions';
  static const String _model = 'openai/gpt-4o-mini';
  
  /// System prompt for the AI mentor
  static const String _systemPrompt = '''
You are a warm, supportive study mentor in an app called StudyBuddy. Your personality:
- Friendly and empathetic, like a wise older friend
- Non-judgmental - never make users feel bad about their struggles
- Use occasional emojis (1-2 per message max)
- Keep responses SHORT (2-3 sentences max)
- Focus on understanding, not lecturing

Your goal in this conversation:
1. Build trust with the user
2. Understand their current focus/study situation
3. Learn about their past struggles with consistency
4. Discover what motivates them
5. Help them feel hopeful about building a study habit

Remember: You're having a conversation, not conducting an interview. Be natural and warm.
''';

  final List<Map<String, String>> _conversationHistory = [];
  
  GeminiService() {
    // Initialize with system prompt
    _conversationHistory.add({
      'role': 'system',
      'content': _systemPrompt,
    });
  }
  
  /// Send a message and get a response
  Future<String> sendMessage(String userMessage) async {
    final shortMessage = userMessage.length > 50 ? '${userMessage.substring(0, 50)}...' : userMessage;
    debugPrint('🤖 GPT-5: Sending message: $shortMessage');
    
    // Add user message to history
    _conversationHistory.add({
      'role': 'user',
      'content': userMessage,
    });
    
    try {
      debugPrint('🤖 GPT-5: Making API request...');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _conversationHistory,
        }),
      );
      
      debugPrint('🤖 GPT-5: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        
        final shortResponse = text.length > 100 ? '${text.substring(0, 100)}...' : text;
        debugPrint('🤖 GPT-5: ✅ API SUCCESS - Response: $shortResponse');
        
        // Add AI response to history
        _conversationHistory.add({
          'role': 'assistant',
          'content': text,
        });
        
        return text;
      } else {
        debugPrint('🤖 GPT-5: ❌ API ERROR: ${response.statusCode} - ${response.body}');
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('🤖 GPT-5: ❌ ERROR - $e');
      // Rethrow so caller can handle
      rethrow;
    }
  }
  
  /// Get initial greeting
  Future<String> getInitialGreeting() async {
    return sendMessage(
      'Start the conversation. Greet the user warmly and ask them one simple question to get started - something about how they\'re feeling about studying today. Keep it light and friendly.'
    );
  }
  
  /// Reset conversation
  void reset() {
    _conversationHistory.clear();
    _conversationHistory.add({
      'role': 'system',
      'content': _systemPrompt,
    });
  }
}
