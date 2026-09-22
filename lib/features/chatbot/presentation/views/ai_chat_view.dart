import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_state.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_voice_cubit.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_composer.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_history_drawer.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_message_bubble.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/scroll_to_bottom_button.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/suggested_questions_grid.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/typing_indicator.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatbotCubit>(
          create: (context) => getIt<ChatbotCubit>()..initializeChat(),
        ),
        BlocProvider<ChatbotVoiceCubit>(
          create: (context) => getIt<ChatbotVoiceCubit>(),
        ),
      ],
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
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final isFarFromBottom = (maxScroll - currentScroll) > 120;

    if (isFarFromBottom != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = isFarFromBottom;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18.r,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              s.aiAssistant,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: s.newChat,
            icon: Icon(Icons.add_comment_outlined, size: 22.r),
            onPressed: () {
              context.read<ChatbotCubit>().initializeChat();
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty && !_showScrollToBottom) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatbotCubit>();

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              vertical: 20.h,
                              horizontal: 16.w,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 16.h),
                                // AI Illustration / Glowing Icon
                                Container(
                                  padding: EdgeInsets.all(22.r),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.primaryColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 20.r,
                                        spreadRadius: 2.r,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 48.r,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  s.howCanIHelpYouToday,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  child: Text(
                                    s.chatEmptySubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.hintColor,
                                      fontSize: 13.5.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
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
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount:
                                state.messages.length +
                                (state.isGenerating ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < state.messages.length) {
                                final message = state.messages[index];
                                final isLastAi =
                                    (index == state.messages.length - 1) &&
                                    (message.sender == MessageSender.ai);
                                return ChatMessageBubble(
                                  message: message,
                                  isLastAiMessage: isLastAi,
                                );
                              } else {
                                // Polished Typing Loading State
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(7.r),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome,
                                          size: 16.r,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[850]
                                              : theme
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.45),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '✨',
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                            SizedBox(width: 6.w),
                                            const TypingIndicator(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                  ChatComposer(
                    isGenerating: state.isGenerating,
                    onSendMessage: (prompt) {
                      cubit.sendMessage(prompt);
                    },
                  ),
                ],
              ),

              // Floating Scroll-to-bottom button
              Positioned(
                bottom: 75.h,
                right: 16.w,
                child: ScrollToBottomButton(
                  isVisible: _showScrollToBottom && state.messages.isNotEmpty,
                  hasNewMessages: state.isGenerating,
                  onPressed: () {
                    _scrollToBottom();
                    setState(() {
                      _showScrollToBottom = false;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
