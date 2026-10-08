import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import '../../domain/entities/chat_entity.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';

class ChatHistoryDrawer extends StatelessWidget {
  const ChatHistoryDrawer({super.key});

  Map<String, List<ChatEntity>> _groupChats(
    BuildContext context,
    List<ChatEntity> chats,
  ) {
    final s = context.l10n;
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
    final s = context.l10n;
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          s.deleteChat,
          style: TextStyle(color: colors.onSurface),
        ),
        content: Text(
          s.confirmDeleteChat,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatbotCubit>().deleteChat(chat.id);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context) {
    final s = context.l10n;
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          s.clearAllChats,
          style: TextStyle(color: colors.onSurface),
        ),
        content: Text(
          s.confirmClearAllChats,
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatbotCubit>().clearAllChats();
            },
            child: Text(s.clear),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.l10n;
    final colors = context.colors;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with New Chat
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.primary,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        s.chatHistory,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
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
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(Icons.add_rounded, size: 20.r),
                      label: Text(
                        s.newChat,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.4)),

            // History List
            Expanded(
              child: BlocBuilder<ChatbotCubit, ChatbotState>(
                builder: (context, state) {
                  final grouped = _groupChats(context, state.chatHistory);

                  if (state.chatHistory.isEmpty) {
                    return Center(
                      child: Text(
                        s.noHistoryYet,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final groupTitle = grouped.keys.elementAt(index);
                      final chats = grouped[groupTitle]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              groupTitle,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...chats.map((chat) {
                            final isSelected = chat.id == state.activeChatId;
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              selectedTileColor: colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 2.h,
                              ),
                              leading: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18.r,
                                color: isSelected
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                              title: Text(
                                chat.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colors.primary
                                      : colors.onSurface,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18.r,
                                  color: colors.onSurfaceVariant,
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

            Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.4)),
            // Clear All Button
            BlocBuilder<ChatbotCubit, ChatbotState>(
              builder: (context, state) {
                if (state.chatHistory.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.all(8.r),
                  child: TextButton.icon(
                    onPressed: () => _showClearAllConfirmDialog(context),
                    icon: Icon(
                      Icons.delete_sweep_rounded,
                      color: colors.error,
                      size: 20.r,
                    ),
                    label: Text(
                      s.clearAllChats,
                      style: TextStyle(color: colors.error),
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
