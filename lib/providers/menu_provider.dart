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
