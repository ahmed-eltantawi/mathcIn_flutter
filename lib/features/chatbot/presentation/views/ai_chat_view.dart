import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/generated/l10n.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/suggested_questions_grid.dart';
import '../widgets/typing_indicator.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatbotCubit>(
      create: (context) => getIt<ChatbotCubit>()..initializeChat(),
      child: const _AiChatViewBody(),
    );
  }
}

class _AiChatViewBody extends StatefulWidget {
  const _AiChatViewBody();

  @override
  State<_AiChatViewBody> createState() => _AiChatViewBodyState();
}

class _AiChatViewBodyState extends State<_AiChatViewBody> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              s.aiAssistant,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: s.newChat,
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              context.read<ChatbotCubit>().initializeChat();
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatbotCubit>();

          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 56,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.howCanIHelpYouToday,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SuggestedQuestionsGrid(
                              onSelectQuestion: (prompt) {
                                cubit.sendMessage(prompt);
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount:
                            state.messages.length + (state.isGenerating ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < state.messages.length) {
                            final message = state.messages[index];
                            return ChatMessageBubble(message: message);
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const TypingIndicator(),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
              ),
              ChatInputBar(
                isGenerating: state.isGenerating,
                onSendMessage: (prompt) {
                  cubit.sendMessage(prompt);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
