import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.readAt,
    required this.isRead,
    this.createdAt,
    this.data,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final String? readAt;
  final bool isRead;
  final String? createdAt;
  final Map<String, dynamic>? data;

  NotificationEntity copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    String? readAt,
    bool? isRead,
    String? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    message,
    readAt,
    isRead,
    createdAt,
    data,
  ];
}
