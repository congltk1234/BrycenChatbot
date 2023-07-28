import 'package:flutter/material.dart';

@immutable
class ChatModel {
  final String id;
  final String message;
  final bool isUser;

  const ChatModel({
    required this.id,
    required this.message,
    required this.isUser,
  });
}
