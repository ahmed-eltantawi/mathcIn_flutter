import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import '../widgets/ai_chat_composer.dart';
import '../widgets/ai_chat_empty_state.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_message_bubble.dart';
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
    final l10n = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (ctx) {
            return IconButton(
              tooltip: l10n.openMenu,
              icon: Icon(
                Icons.menu_rounded,
                size: 24.r,
                color: colors.onSurface,
              ),
              onPressed: () {
                Scaffold.of(ctx).openDrawer();
              },
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 18.r,
                color: colors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.aiAssistant,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.newChat,
            icon: Icon(
              Icons.add_comment_outlined,
              size: 22.r,
              color: colors.onSurface,
            ),
            onPressed: () {
              context.read<ChatbotCubit>().initializeChat();
            },
          ),
          SizedBox(width: 4.w),
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
                    ? AiChatEmptyState(
                        onSelectQuestion: (prompt) {
                          cubit.sendMessage(prompt);
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemCount:
                            state.messages.length + (state.isGenerating ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < state.messages.length) {
                            final message = state.messages[index];
                            return ChatMessageBubble(message: message);
                          } else {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color:
                                          colors.primary.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 16.r,
                                      color: colors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerHighest
                                          .withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(18.r),
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
              AiChatComposer(
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
