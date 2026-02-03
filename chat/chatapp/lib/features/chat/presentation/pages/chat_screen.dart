import 'package:chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  final String otherUserId;

  const ChatScreen({super.key, required this.otherUserId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc()..add(ConnectSocket('your-jwt-token', 'your-user-id')),
      child: Scaffold(
        appBar: AppBar(title: Text('Chat with $otherUserId')),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatMessagesLoaded) {
              final currentUserId =
                  'your-user-id'; // ← get this from auth / bloc / provider

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];

                  // Decide if this message is from me
                  final isMe = msg.senderId == currentUserId;

                  return MessageBubble(
                    message: msg,
                    isMe: isMe, // ← this was missing
                  );
                },
              );
            }

            return const Center(child: Text('Error or disconnected'));
          },
        ),
        bottomNavigationBar: _buildInputField(context),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<ChatBloc>().add(SendMessage(otherUserId, text));
                controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
