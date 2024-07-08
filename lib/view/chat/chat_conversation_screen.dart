import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/controller/chat_service.dart';

class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String currentUserId;

  ChatConversationScreen({
    required this.chatId,
    required this.userName,
    required this.currentUserId,
  });

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          children: [
            // CircleAvatar(
            //   radius: 20,
            //   backgroundImage: NetworkImage(
            //       'https://via.placeholder.com/150'), // Placeholder image
            // ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cửa hàng",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Text('Online',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages'));
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == widget.currentUserId;
                    final messageTime = (message['timestamp'] as Timestamp?)
                            ?.toDate()
                            .toLocal() ??
                        DateTime.now();
                    final formattedTime =
                        '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}';

                    return ListTile(
                      title: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          formattedTime,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      chatService.sendMessage(
                          widget.chatId, message, widget.currentUserId);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
