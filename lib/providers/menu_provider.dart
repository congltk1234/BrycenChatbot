import 'package:brycen_chatbot/models/chatTitle.dart';
import 'package:brycen_chatbot/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usersProvider = Provider(
  ((ref) {
    return UserModel(uid: 'abc', username: 'dummy usser', apiKey: 'afjdjs');
  }),
);

class SummaryNotifier extends StateNotifier<List<UserModel>> {
  SummaryNotifier() : super([]);
  void fetchDatafromFireStore() async {
    final users = await FirebaseFirestore.instance.collection("users").get();
    List<UserModel> usersList = [];
    for (var element in users.docs) {
      // final option = Text(element.data()['Username']);
      usersList.add(UserModel(
          uid: element.id,
          username: element.data()['Username'],
          // chatDate: element.data()['createdAt'],
          apiKey: element.data()['APIkey']));
    }
    state = usersList;
  }

  void addData(UserModel user) {
    // final mealIsFavorite = state.contains(user);
    state = [...state, user];
  }
}

final summaryProvider = StateNotifierProvider<SummaryNotifier, List<UserModel>>(
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
        .orderBy('modifiredAt', descending: true)
        .get();
    List<ChatTitleModel> chatTitlesList = [];
    for (var element in chatTitles.docs) {
      // final option = Text(element.data()['Username']);
      chatTitlesList.add(ChatTitleModel(
          chatid: element.id,
          chattitle: element.data()['chatTitle'],
          // chatDate: element.data()['createdAt'],
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
