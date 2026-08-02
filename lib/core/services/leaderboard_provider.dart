import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kids_models.dart';

final leaderboardStreamProvider = StreamProvider<List<UserProfileModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('xp', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => UserProfileModel.fromJson(doc.data()))
        .toList();
  });
});
