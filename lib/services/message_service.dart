import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../api_url.dart';

class MessageService {
  // Get messages between current user and another user
  static Future<List<Message>> getMessages(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse(ApiUrl.getMessagesUrl(userId)),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Handle paginated response from Laravel
        final messagesData = data['messages'];
        if (messagesData is Map && messagesData['data'] != null) {
          return (messagesData['data'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList();
        } else if (messagesData is List) {
          // Direct list response (fallback)
          return (messagesData as List)
              .map((msg) => Message.fromJson(msg))
              .toList();
        } else {
          throw Exception('Invalid messages format in response');
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to load messages');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Messages not found');
    } else if (response.statusCode == 500) {
      throw Exception('Server error');
    }
    
    throw Exception('Failed to load messages: ${response.statusCode}');
  }

  // Get all messages for current user (for notifications)
  static Future<List<Message>> getAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('user_id');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Use the conversations endpoint to get all conversations, then get messages from the first conversation
    final endpoints = [
      {
        'url': '${ApiUrl.baseUrl}/messages/conversations',
        'method': 'GET',
        'body': null,
        'description': 'GET /api/messages/conversations (get all conversations first)'
      },
    ];
    
    for (int i = 0; i < endpoints.length; i++) {
      final endpoint = endpoints[i];
      final url = endpoint['url'] as String;
      final method = endpoint['method'] as String;
      final body = endpoint['body'] as Map<String, dynamic>?;
      final description = endpoint['description'] as String;
      
      debugPrint('Trying endpoint ${i + 1}: $description');
      debugPrint('URL: $url, Method: $method');
      
      final response = method == 'POST' 
        ? await http.post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
        : await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );
      
      debugPrint('Response ${i + 1} - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        debugPrint('Success with endpoint: $url');
        debugPrint('Response Body: ${response.body}');
        
        final data = jsonDecode(response.body);
        if (data['success']) {
          // Handle conversations response
          final conversationsData = data['conversations'];
          debugPrint('Conversations Data: $conversationsData');
          
          if (conversationsData is List && conversationsData.isNotEmpty) {
            // Get the first conversation and fetch its messages
            final firstConversation = conversationsData[0];
            final otherUserId = firstConversation['other_user_id'];
            debugPrint('Getting messages with user ID: $otherUserId');
            
            // Now fetch messages with this user
            final messagesResponse = await http.get(
              Uri.parse(ApiUrl.getMessagesUrl(otherUserId)),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );
            
            if (messagesResponse.statusCode == 200) {
              final messagesData = jsonDecode(messagesResponse.body);
              if (messagesData['success']) {
                final messages = messagesData['messages'];
                if (messages is Map && messages['data'] != null) {
                  final messagesList = messages['data'] as List;
                  debugPrint('Messages List Length: ${messagesList.length}');
                  
                  final parsedMessages = messagesList
                      .map((msg) => Message.fromJson(msg))
                      .toList();
                  debugPrint('Parsed Messages Count: ${parsedMessages.length}');
                  return parsedMessages;
                }
              }
            }
          }
          
          // If no conversations or failed to get messages, return empty list
          debugPrint('No conversations found or failed to get messages');
          return [];
        } else {
          debugPrint('API returned success: false, message: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to load messages');
        }
      } else {
        debugPrint('Endpoint ${i + 1} failed with status: ${response.statusCode}');
        if (i == endpoints.length - 1) {
          // Last attempt failed, throw error
          throw Exception('All message endpoints failed. Last status: ${response.statusCode}');
        }
      }
    }
    
    throw Exception('No working message endpoint found');
  }

  // Mark all messages from a specific sender as read
  static Future<void> markMessagesAsRead(int senderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/messages/mark-read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'sender_id': senderId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        debugPrint('Successfully marked messages as read from sender: $senderId');
      } else {
        throw Exception(data['message'] ?? 'Failed to mark messages as read');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else if (response.statusCode == 404) {
      throw Exception('Messages not found');
    } else {
      throw Exception('Failed to mark messages as read: ${response.statusCode}');
    }
  }

  // Get only unread message count (without fetching all messages)
  static Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/messages/unread/count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['unread_count'] ?? 0;
      } else {
        throw Exception(data['message'] ?? 'Failed to get unread count');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      throw Exception('Failed to get unread count: ${response.statusCode}');
    }
  }
}