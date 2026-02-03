import 'package:chat/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/message_entity.dart';


abstract class ChatRepository {
  Future<Either<Failure, Unit>> sendMessage(String otherUserId, String text);
  Stream<MessageEntity> getMessageStream(String chatId);
  Future<Either<Failure, Unit>> markAsDelivered(String msgId, String chatId);
  Future<Either<Failure, Unit>> markAsRead(String chatId, List<String> msgIds);
}
