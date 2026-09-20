import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../generated/l10n.dart';
import '../../domain/entities/chat_entity.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';

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

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  void _showDeleteConfirmDialog(BuildContext context, ChatEntity chat) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteChat),
        content: Text(s.confirmDeleteChat),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatbotCubit>().deleteChat(chat.id);
            },
            child: Text(s.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAllConversations),
        content: Text(s.undoWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatbotCubit>().clearAllChats();
            },
            child: Text(s.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
            // Drawer Header with New Chat Button
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: theme.primaryColor,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        s.chatHistory,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<ChatbotCubit>().initializeChat();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                      label: Text(
                        s.newChat,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.h),

            // History List
            Expanded(
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  final grouped = _groupChats(context, state.chatHistory);

                  if (state.chatHistory.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48.r,
                            color: theme.hintColor.withValues(alpha: 0.4),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            s.noConversationsYet,
                            style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
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
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              selectedTileColor: theme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 0,
                              ),
                              leading: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18.r,
                                color: isSelected
                                    ? theme.primaryColor
                                    : theme.hintColor,
                              ),
                              title: Text(
                                chat.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected ? theme.primaryColor : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18.r,
                                  color: theme.hintColor.withValues(alpha: 0.7),
                                ),
                                onPressed: () =>
                                    _showDeleteConfirmDialog(context, chat),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                context.read<ChatbotCubit>().selectChat(
                                  chat.id,
                                );
                              },
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
