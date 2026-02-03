import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketDataSource {
  final IO.Socket socket;

  SocketDataSource(this.socket);

  void sendMessage(String otherUserId, String text) {
    socket.emit('send-message', {'otherUserId': otherUserId, 'text': text});
  }

  // other methods: joinChat, markDelivered, markRead, listen events...
}
