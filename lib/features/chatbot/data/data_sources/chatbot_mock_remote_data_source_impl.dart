import 'dart:async';
import '../../domain/entities/chat_message_entity.dart';
import '../models/chat_message_model.dart';
import '../models/chat_model.dart';
import '../models/chatbot_send_message_response_model.dart';
import '../models/suggested_action_model.dart';
import 'chatbot_remote_data_source.dart';

class ChatbotMockRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final List<ChatModel> _sessions = [];

  @override
  Future<List<ChatModel>> getConversations() async {
    return List.unmodifiable(_sessions);
  }

  @override
  Future<ChatModel> getConversationDetails(String conversationId) async {
    return _sessions.firstWhere(
      (s) => s.id == conversationId,
      orElse: () => ChatModel(
        id: conversationId,
        title: 'Interview Preparation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: const [],
      ),
    );
  }

  @override
  Future<ChatModel> createConversation({
    String? title,
    String? message,
    String? contextMode,
    int? jobPostId,
  }) async {
    final convoId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final initialTitle = title ?? (message != null && message.length > 30 ? '${message.substring(0, 30)}...' : 'New Chat');

    final messages = <ChatMessageModel>[];
    if (message != null && message.isNotEmpty) {
      messages.add(
        ChatMessageModel(
          id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
          content: message,
          sender: MessageSender.user,
          timestamp: DateTime.now(),
        ),
      );
      messages.add(
        ChatMessageModel(
          id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
          content: _generateSmartResponse(message),
          sender: MessageSender.ai,
          timestamp: DateTime.now().add(const Duration(milliseconds: 100)),
          suggestedActions: const [
            SuggestedActionModel(
              type: 'suggested_prompt',
              label: 'Tell me more about state management',
            ),
            SuggestedActionModel(
              type: 'suggested_prompt',
              label: 'Review my resume roadmap',
            ),
          ],
        ),
      );
    }

    final session = ChatModel(
      id: convoId,
      title: initialTitle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: messages,
      jobPostId: jobPostId,
      contextMode: contextMode,
    );

    _sessions.insert(0, session);
    return session;
  }

  @override
  Future<ChatbotSendMessageResponseModel> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final responseText = _generateSmartResponse(message);

    final userMsg = ChatMessageModel(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      content: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final aiReply = ChatMessageModel(
      id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
      content: responseText,
      sender: MessageSender.ai,
      timestamp: DateTime.now().add(const Duration(milliseconds: 50)),
      suggestedActions: const [
        SuggestedActionModel(
          type: 'suggested_prompt',
          label: 'How do I optimize app performance?',
        ),
        SuggestedActionModel(
          type: 'suggested_prompt',
          label: 'Review system design concepts',
        ),
      ],
    );

    return ChatbotSendMessageResponseModel(
      userMessage: userMsg,
      mentorReply: aiReply,
    );
  }

  @override
  Future<void> updateConversation({
    required String conversationId,
    String? title,
    bool? isArchived,
  }) async {
    final index = _sessions.indexWhere((s) => s.id == conversationId);
    if (index >= 0) {
      final s = _sessions[index];
      _sessions[index] = ChatModel(
        id: s.id,
        title: title ?? s.title,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
        messages: s.messages,
        isArchived: isArchived ?? s.isArchived,
        jobPostId: s.jobPostId,
        contextMode: s.contextMode,
      );
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    _sessions.removeWhere((s) => s.id == conversationId);
  }

  @override
  Future<Map<String, dynamic>> getContextPreview() async {
    return {
      'headline': 'Senior Flutter Engineer',
      'skills': ['Flutter', 'Dart', 'Bloc', 'Clean Architecture'],
      'target_role': 'Mobile Architect',
    };
  }

  String _generateSmartResponse(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('resume') || lower.contains('cv') || lower.contains('سيرة')) {
      return '''Here are 3 quick tips to improve your resume for Tech roles:

1. **Highlight Impact with Metrics**: Use numbers (e.g., "Increased app speed by 35%").
2. **Tailor Keywords**: Match skills from the job description (e.g., Flutter, BLoC, Clean Architecture).
3. **Keep it Concise**: Limit to 1-2 pages focusing on your most relevant projects.

Would you like me to help review a specific section of your CV?''';
    }

    if (lower.contains('interview') || lower.contains('مقابلة') || lower.contains('أسئلة')) {
      return '''Top Flutter interview topics to prepare:

• **State Management**: BLoC vs Provider vs Riverpod lifecycle & architectural patterns.
• **Dart Internals**: Isolates, Event Loop, Futures, and Microtasks.
• **Performance Tuning**: `const` constructors, repaint boundary, and list optimization.
• **Testing**: Unit tests, Widget tests, and Mocking.

Shall we simulate a technical interview question together?''';
    }

    return '''Thank you for reaching out! I am your MatchIn AI Career & Tech Assistant.

I can help you with:
- **Resume & Profile Optimization**
- **Technical & Behavioral Interview Prep**
- **Flutter & Mobile Architecture Guidance**
- **Career Growth & Roadmap Planning**

Feel free to ask me any question!''';
  }
}
