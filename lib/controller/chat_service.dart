import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendMessage(
      String chatId, String message, String senderId) async {
    final messageData = {
      'message': message,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
    await _firestore
        .collection('chats')
        .doc(chatId)
        .update({'lastMessage': message});
  }

  Future<String> createChat(
      String userId, String adminId, String userName, String adminName) async {
    final chatDoc = await _firestore.collection('chats').add({
      'participants': [userId, adminId],
      'lastMessage': '',
      'userName': userName,
      'adminName': adminName,
      'adminId': adminId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return chatDoc.id;
  }
}
