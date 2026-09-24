import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/widgets/delete_confirmation_dialog.dart';
import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_state.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_drawer_header.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_history_empty_state.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_history_item_tile.dart';
import 'package:MatchIn/generated/l10n.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  Map<String, List<ChatEntity>> _groupChats(
    BuildContext context,
    List<ChatEntity> chats,
  ) {
    final s = S.of(context);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(const Duration(days: 7));

    final Map<String, List<ChatEntity>> grouped = {
      s.today: [],
      s.yesterday: [],
      s.previous7Days: [],
      s.older: [],
    };

    for (final chat in chats) {
      if (chat.updatedAt.isAfter(todayStart)) {
        grouped[s.today]!.add(chat);
      } else if (chat.updatedAt.isAfter(yesterdayStart)) {
        grouped[s.yesterday]!.add(chat);
      } else if (chat.updatedAt.isAfter(weekStart)) {
        grouped[s.previous7Days]!.add(chat);
      } else {
        grouped[s.older]!.add(chat);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  void _showDeleteConfirmDialog(BuildContext context, ChatEntity chat) {
    final s = S.of(context);
    final chatbotCubit = context.read<ChatbotCubit>();
    showDeleteConfirmationDialog(
      context: context,
      title: s.deleteChat,
      message: s.confirmDeleteChat,
      onConfirm: () async => await chatbotCubit.deleteChat(chat.id),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context) {
    final s = S.of(context);
    final chatbotCubit = context.read<ChatbotCubit>();
    showDeleteConfirmationDialog(
      context: context,
      title: s.deleteAllConversations,
      message: s.undoWarning,
      onConfirm: () async => await chatbotCubit.clearAllChats(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.grey[900] : theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            const ChatDrawerHeader(),
            Divider(height: 1.h),

            // History List
            Expanded(
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  final grouped = _groupChats(context, state.chatHistory);

                  if (state.chatHistory.isEmpty) {
                    return const ChatHistoryEmptyState();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 8.w,
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final groupTitle = grouped.keys.elementAt(index);
                      final chats = grouped[groupTitle]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              groupTitle,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ),
                          ...chats.map((chat) {
                            final isSelected = chat.id == state.activeChatId;
                            return ChatHistoryItemTile(
                              chat: chat,
                              isSelected: isSelected,
                              onSelect: () {
                                Navigator.pop(context);
                                context.read<ChatbotCubit>().selectChat(
                                      chat.id,
                                    );
                              },
                              onDelete: () =>
                                  _showDeleteConfirmDialog(context, chat),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            Divider(height: 1.h),
            // Clear All Button
            BlocBuilder<ChatbotCubit, ChatbotState>(
              builder: (context, state) {
                if (state.chatHistory.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.all(12.r),
                  child: TextButton.icon(
                    onPressed: () => _showClearAllConfirmDialog(context),
                    icon: Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.red,
                      size: 20.r,
                    ),
                    label: Text(
                      s.clearAllChats,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
