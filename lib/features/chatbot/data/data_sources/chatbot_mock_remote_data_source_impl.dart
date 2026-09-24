import 'dart:async';
import 'dart:math';
import '../../domain/entities/chat_message_entity.dart';
import '../models/chat_message_model.dart';
import 'chatbot_remote_data_source.dart';

class ChatbotMockRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  @override
  Future<ChatMessageModel> sendMessage({
    required String chatId,
    required String messageContent,
    required List<ChatMessageModel> history,
  }) async {
    // Simulate network latency
    await Future.delayed(Duration(milliseconds: 900 + Random().nextInt(600)));

    final responseText = _generateSmartResponse(messageContent);

    return ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      content: responseText,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );
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
• **Performance Tuning**: `const` constructors, repaintd boundary, and list optimization.
• **Testing**: Unit tests, Widget tests, and Mocking.

Shall we simulate a technical interview question together?''';
    }

    if (lower.contains('flutter') || lower.contains('dart') || lower.contains('cubit')) {
      return '''Flutter is Google's UI toolkit for building natively compiled applications from a single codebase.

Key architectural recommendations:
- **Clean Architecture**: Separate Domain, Data, and Presentation layers.
- **State Management**: Cubit/BLoC for reactive state management.
- **Dependency Injection**: Use `get_it` for decoupling dependencies.

Let me know if you want code examples!''';
    }

    if (lower.contains('job') || lower.contains('career') || lower.contains('عمل') || lower.contains('وظيفة')) {
      return '''Based on your profile, here are strategic career steps:

1. **Build Proof of Work**: Publish open-source Flutter packages or apps on GitHub.
2. **Target High-Match Roles**: Use MatchIn's Job Match feature to view direct skill fit.
3. **Prepare System Design**: Practice designing scalable frontend Flutter architectures.

How else can I support your career journey today?''';
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
