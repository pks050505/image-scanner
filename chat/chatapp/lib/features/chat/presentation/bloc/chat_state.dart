part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnected extends ChatState {
  final String userId;
  const ChatConnected(this.userId);
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  const ChatMessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatMessageSent extends ChatState {
  final MessageEntity message;
  const ChatMessageSent(this.message);
}

class ChatError extends ChatState {
  final String error;
  const ChatError(this.error);
}
