import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/functions/require_auth.dart';
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

  void _showContextPreviewSheet(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final cubit = context.read<ChatbotCubit>();
    cubit.loadContextPreview();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: MediaQuery.of(sheetContext).padding.bottom + 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        size: 20.r,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.careerMentor,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          Text(
                            l10n.contextPreview,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18.r,
                        color: colors.primary,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10n.careerGroundingContext,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                BlocBuilder<ChatbotCubit, ChatbotState>(
                  builder: (context, state) {
                    final preview = state.contextPreview;
                    if (preview == null || preview.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: preview.entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5.sp,
                                  color: colors.onSurface,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${entry.value}',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 220.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
            width: 180.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            width: 260.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ],
    );
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
        title: BlocBuilder<ChatbotCubit, ChatbotState>(
          builder: (context, state) {
            final title = state.activeChatTitle.isNotEmpty
                ? state.activeChatTitle
                : l10n.aiAssistant;

            return Row(
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
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: l10n.contextPreview,
            icon: Icon(
              Icons.info_outline_rounded,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
            onPressed: () => _showContextPreviewSheet(context),
          ),
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
          if (state.isAuthRequired) {
            requireAuth(context);
          }
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final cubit = context.read<ChatbotCubit>();

          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  color: colors.error.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 16.r,
                        color: colors.error,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          l10n.offlineStatusShowingSaved,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: state.isOpeningChat
                    ? _buildSkeletonLoader(context)
                    : state.messages.isEmpty
                        ? AiChatEmptyState(
                            onSelectQuestion: (prompt) {
                              cubit.sendMessage(prompt);
                            },
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            itemCount: state.messages.length +
                                (state.isGenerating ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < state.messages.length) {
                                final message = state.messages[index];
                                return ChatMessageBubble(
                                  message: message,
                                  onRetry: message.isError
                                      ? () => cubit.retryLastFailedMessage()
                                      : null,
                                  onSelectPrompt: (prompt) =>
                                      cubit.sendMessage(prompt),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(
                                            alpha: 0.12,
                                          ),
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
                                          borderRadius:
                                              BorderRadius.circular(18.r),
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
