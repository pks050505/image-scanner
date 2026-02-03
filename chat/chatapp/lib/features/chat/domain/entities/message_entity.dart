import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final String receiverId;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.receiverId,
    this.status = MessageStatus.sent,
  });
MessageEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
  @override
  List<Object?> get props => [id, senderId, text, timestamp, status];
}

enum MessageStatus { sent, delivered, read }
extension MessageStatusExtension on MessageStatus {
  static MessageStatus fromString(String value) {
    try {
      return MessageStatus.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return MessageStatus.sent;
    }
  }
}
