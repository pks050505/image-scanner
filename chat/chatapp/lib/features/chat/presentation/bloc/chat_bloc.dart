import 'package:chat/features/chat/data/models/message_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

import '../../domain/entities/message_entity.dart'; // MessageEntity यहाँ से आ रहा है

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  IO.Socket? _socket;
  String? _currentUserId;
  final List<MessageEntity> _messages = [];
  final _uuid = const Uuid();

  ChatBloc() : super(ChatInitial()) {
    on<ConnectSocket>(_onConnectSocket);
    on<JoinChat>(_onJoinChat);
    on<SendMessage>(_onSendMessage);
    on<ReceiveNewMessage>(_onReceiveNewMessage);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<MarkDelivered>(_onMarkDelivered);
    on<MarkRead>(_onMarkRead);
    on<DisconnectSocket>(_onDisconnect);
  }

  Future<void> _onConnectSocket(
    ConnectSocket event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    _currentUserId = event.userId;

    try {
      _socket = IO.io(
        'https://your-cloud-run-url.a.run.app', // ← अपना असली Cloud Run URL डालो
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': event.jwtToken})
            .disableAutoConnect()
            .build(),
      );

      _socket?.connect();

      _socket?.onConnect((_) {
        emit(ChatConnected(event.userId));
      });

      _socket?.on('new-message', (data) {
        if (data is Map<String, dynamic>) {
          add(ReceiveNewMessage(data));
        }
      });

      _socket?.on('message-status', (data) {
        if (data is Map<String, dynamic>) {
          add(UpdateMessageStatus(data));
        }
      });

      _socket?.onDisconnect((_) {
        emit(const ChatError('Disconnected from server'));
      });

      _socket?.onError((err) {
        emit(ChatError('Socket error: $err'));
      });
    } catch (e) {
      emit(ChatError('Failed to connect: $e'));
    }
  }

  void _onJoinChat(JoinChat event, Emitter<ChatState> emit) {
    if (_currentUserId == null || _socket == null) return;

    // 1-on-1 room: दोनों IDs sorted
    final ids = [_currentUserId!, event.otherUserId]..sort();
    final room = 'private:${ids.join('_')}';

    _socket!.emit('join-chat', event.otherUserId);
    // Optional: यहाँ Firestore से पुराने messages load कर सकते हो
    // और _messages.addAll(loadedMessages);
    // emit(ChatMessagesLoaded(List.from(_messages)));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    if (_currentUserId == null || _socket == null) return;

    final msg = MessageEntity(
      id: _uuid.v4(), // client-side generate (backend override कर सकता है)
      senderId: _currentUserId!,
      receiverId: event.otherUserId,
      text: event.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Optimistic UI update: तुरंत दिखाओ
    _messages.add(msg);
    emit(ChatMessagesLoaded(List.from(_messages)));

    // Backend को भेजो
    _socket!.emit('send-message', {
      'otherUserId': event.otherUserId,
      'text': event.text,
    });
  }

void _onReceiveNewMessage(ReceiveNewMessage event, Emitter<ChatState> emit) {
    // JSON → Model → Entity
    final modelMsg = MessageModel.fromJson(event.messageData);
    final entityMsg = modelMsg.toEntity();

    if (_messages.any((m) => m.id == entityMsg.id)) return;

    _messages.add(entityMsg);
    emit(ChatMessagesLoaded(List.from(_messages)));
  }

  void _onUpdateMessageStatus(
    UpdateMessageStatus event,
    Emitter<ChatState> emit,
  ) {
    final msgId = event.statusData['id'] as String?;
    final statusStr = event.statusData['status'] as String?;

    if (msgId == null || statusStr == null) return;

    final newStatus = MessageModel.parseStatus(statusStr);

    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].id == msgId) {
        // Entity immutable है → नया entity बनाओ
        _messages[i] = MessageEntity(
          id: _messages[i].id,
          senderId: _messages[i].senderId,
          receiverId: _messages[i].receiverId,
          text: _messages[i].text,
          timestamp: _messages[i].timestamp,
          status: newStatus,
        );
        break;
      }
    }

    emit(ChatMessagesLoaded(List.from(_messages)));
  }
  void _onMarkDelivered(MarkDelivered event, Emitter<ChatState> emit) {
    // Local update अगर जरूरत हो (backend से status update आएगा)
    // अभी सिर्फ emit backend को (अगर अलग event हो)
  }

  void _onMarkRead(MarkRead event, Emitter<ChatState> emit) {
    if (_socket == null) return;

    _socket!.emit('messages-read', {
      'chatId': event.chatId,
      'msgIds': event.msgIds,
    });

    // Optimistic: local में read mark कर दो
    for (var i = 0; i < _messages.length; i++) {
      if (event.msgIds.contains(_messages[i].id)) {
        _messages[i] = _messages[i].copyWith(status: MessageStatus.read);
      }
    }

    emit(ChatMessagesLoaded(List.from(_messages)));
  }

  void _onDisconnect(DisconnectSocket event, Emitter<ChatState> emit) {
    _socket?.disconnect();
    _messages.clear();
    emit(ChatInitial());
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket = null;
    return super.close();
  }
}
