import '../models/suggestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuggestNotifier extends StateNotifier<List<SuggestModel>> {
  SuggestNotifier() : super([]);

  void fetchDatafromFireStore(String uid, String chatID) async {
    final getList = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('summarize')
        .doc(chatID)
        .collection('suggestion')
        .orderBy('createdAt', descending: true)
        .get();
    List<SuggestModel> suggestList = [];
    print('Load suggest');
    for (var element in getList.docs) {
      suggestList.add(SuggestModel(
        id: element.id,
        suggestQuestion: element.data()['suggestQuestion'],
      ));
    }
    state = suggestList;
  }
}

final suggestProvider =
    StateNotifierProvider<SuggestNotifier, List<SuggestModel>>(
  ((ref) {
    return SuggestNotifier();
  }),
);
