part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ConnectSocket extends ChatEvent {
  final String jwtToken;
  final String userId;
  const ConnectSocket(this.jwtToken, this.userId);
}

class JoinChat extends ChatEvent {
  final String otherUserId;
  const JoinChat(this.otherUserId);
}

class SendMessage extends ChatEvent {
  final String otherUserId;
  final String text;
  const SendMessage(this.otherUserId, this.text);
}

class ReceiveNewMessage extends ChatEvent {
  final Map<String, dynamic> messageData;
  const ReceiveNewMessage(this.messageData);
}

class UpdateMessageStatus extends ChatEvent {
  final Map<String, dynamic> statusData;
  const UpdateMessageStatus(this.statusData);
}

class MarkDelivered extends ChatEvent {
  final String msgId;
  final String chatId;
  const MarkDelivered(this.msgId, this.chatId);
}

class MarkRead extends ChatEvent {
  final String chatId;
  final List<String> msgIds;
  const MarkRead(this.chatId, this.msgIds);
}

class DisconnectSocket extends ChatEvent {}
