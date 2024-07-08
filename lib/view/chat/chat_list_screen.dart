import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_conversation_screen.dart';
import '/controller/chat_service.dart';
import '/controller/auth_service.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.getCurrentUserId();

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Chat'),
          centerTitle: true,
        ),
        body: Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Chat',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats available'));
          }
          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat.id;
              final userName = chat['userName'];
              final adminName = chat['adminName'];
              final lastMessage = chat['lastMessage'];

              // Determine the recipient name based on the current user role
              final recipientName =
                  currentUserId == chat['adminId'] ? userName : 'Cửa hàng';

              return ChatItem(
                name: recipientName,
                message: lastMessage,
                time: "1:05 PM", // Placeholder time
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatConversationScreen(
                        chatId: chatId,
                        userName: recipientName,
                        currentUserId: currentUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          String adminId = 'HoOY18KK0ieSccSYeNVLOWyZYdi1';
          String adminName = 'admin1';

          // Get user info
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .get();
          final userName = userDoc['name'];

          // Create a new chat
          final chatId = await chatService.createChat(
              currentUserId, adminId, userName, adminName);

          // Navigate to the chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(
                chatId: chatId,
                userName: adminName,
                currentUserId: currentUserId,
              ),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final VoidCallback onTap;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // CircleAvatar(
            //   radius: 28,
            //   backgroundImage: NetworkImage(
            //       'https://via.placeholder.com/150'), // Placeholder image
            // ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(message, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
