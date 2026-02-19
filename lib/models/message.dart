class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  final DateTime? readAt;
  final UserInfo? sender;
  final UserInfo? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = false,
    this.readAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      body: json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sender: json['sender'] != null ? UserInfo.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? UserInfo.fromJson(json['receiver']) : null,
    );
  }

  // Check if message is from current user
  bool isFromUser(int currentUserId) {
    return senderId == currentUserId;
  }

  // Get the other user's info (either sender or receiver)
  UserInfo? getOtherUser(int currentUserId) {
    return isFromUser(currentUserId) ? receiver : sender;
  }
}

class UserInfo {
  final int id;
  final String name;
  final String username;
  final String userType;

  UserInfo({
    required this.id,
    required this.name,
    required this.username,
    required this.userType,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      userType: json['user_type'] ?? 'user',
    );
  }
}
