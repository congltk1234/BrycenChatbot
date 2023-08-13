import '../models/chatTitle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryNotifier extends StateNotifier<List<ChatTitleModel>> {
  SummaryNotifier() : super([]);
  void fetchDatafromFireStore(
    String uid,
  ) async {
    final chatTitles = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('summarize')
        .orderBy('modifiedAt', descending: true)
        .get();
    List<ChatTitleModel> chatTitlesList = [];
    for (var element in chatTitles.docs) {
      chatTitlesList.add(ChatTitleModel(
          chatid: element.id,
          chattitle: element.data()['chatTitle'],
          // chatDate: element.data()['createdAt'],
          memory: element.data()['memory']));
    }
    state = chatTitlesList;
  }

  void newChat(ChatTitleModel chatTitle) {
    state = [...state, chatTitle];
  }
}

final summaryProvider =
    StateNotifierProvider<SummaryNotifier, List<ChatTitleModel>>(
  ((ref) {
    return SummaryNotifier();
  }),
);

class ChatTitleNotifier extends StateNotifier<List<ChatTitleModel>> {
  ChatTitleNotifier() : super([]);

  void fetchDatafromFireStore(
    String uid,
  ) async {
    final chatTitles = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('chat')
        .orderBy('modifiedAt', descending: true)
        .get();
    List<ChatTitleModel> chatTitlesList = [];
    for (var element in chatTitles.docs) {
      chatTitlesList.add(ChatTitleModel(
          chatid: element.id,
          chattitle: element.data()['chatTitle'],
          memory: element.data()['memory']));
    }
    state = chatTitlesList;
  }

  void newChat(ChatTitleModel chatTitle) {
    // final mealIsFavorite = state.contains(user);
    state = [...state, chatTitle];
  }
}

final chatTitleProvider =
    StateNotifierProvider<ChatTitleNotifier, List<ChatTitleModel>>(
  ((ref) {
    return ChatTitleNotifier();
  }),
);
