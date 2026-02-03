import 'package:chat/core/error/failure.dart';
import 'package:chat/features/chat/data/datasources/socket_data_source.dart';
import 'package:chat/features/chat/domain/entities/message_entity.dart';

import '../../domain/repositories/chat_repository.dart';

import 'package:dartz/dartz.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SocketDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> sendMessage(
    String otherUserId,
    String text,
  ) async {
    try {
      dataSource.sendMessage(otherUserId, text);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<MessageEntity> getMessageStream(String chatId) {
    // TODO: implement getMessageStream
    throw UnimplementedError();
  }

  @override
  markAsDelivered(String msgId, String chatId) {
    // TODO: implement markAsDelivered
    throw UnimplementedError();
  }

  @override
  markAsRead(String chatId, List<String> msgIds) {
    // TODO: implement markAsRead
    throw UnimplementedError();
  }

  // implement other methods...
}
