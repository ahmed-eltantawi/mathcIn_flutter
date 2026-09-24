import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/features/chatbot/domain/entities/chat_entity.dart';

class ChatHistoryItemTile extends StatelessWidget {
  const ChatHistoryItemTile({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
  });

  final ChatEntity chat;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: theme.primaryColor.withValues(alpha: 0.1),
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
        color: isSelected ? theme.primaryColor : theme.hintColor,
      ),
      title: Text(
        chat.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.primaryColor : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 18.r,
          color: theme.hintColor.withValues(alpha: 0.7),
        ),
        onPressed: onDelete,
      ),
      onTap: onSelect,
    );
  }
}
