import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/kids_models.dart';

class StorageService {
  static const String _userKey = 'kg_user_data';
  static const String _questsKey = 'kg_quests_data';
  static const String _zombieKey = 'kg_zombie_stats';
  static const String _skyRushKey = 'kg_sky_rush_stats';
  static const String _turboKartKey = 'kg_turbo_kart_stats';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Local Storage
  static Future<void> saveUserLocal(UserProfileModel user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }

  static UserProfileModel? loadUserLocal() {
    final data = _prefs?.getString(_userKey);
    if (data != null) {
      return UserProfileModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  // Cloud Sync (Firestore)
  static Future<void> syncToCloud(UserProfileModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print("Firestore Sync Error: $e");
    }
  }

  static Future<UserProfileModel?> fetchFromCloud(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print("Firestore Fetch Error: $e");
    }
    return null;
  }

  // Pet Sync
  static Future<void> syncPetToCloud(String uid, PetModel pet) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('data').doc('pet').set({
        'level': pet.level,
        'happiness': pet.happinessPercent,
        'hunger': pet.hungerPercent,
      });
    } catch (e) {
      print("Pet Sync Error: $e");
    }
  }

  // Shop Items Sync
  static Future<void> syncItemsToCloud(String uid, List<ShopItemModel> items) async {
    try {
      final purchasedIds = items.where((e) => e.isPurchased).map((e) => e.id).toList();
      final requestedIds = items.where((e) => e.isRequested).map((e) => e.id).toList();
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('data').doc('items').set({
        'purchased': purchasedIds,
        'requested': requestedIds,
      });
    } catch (e) {
      print("Items Sync Error: $e");
    }
  }

  // Firebase Storage (Image Upload)
  static Future<String?> uploadProfileImage(dynamic imageFile, String uid) async {
    try {
      print("Starting upload for user: $uid");
      final storageRef = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
      
      if (kIsWeb) {
        print("Uploading bytes (Web)");
        await storageRef.putData(imageFile);
      } else {
        print("Uploading file (Mobile): ${(imageFile as File).path}");
        await storageRef.putFile(imageFile as File);
      }
      
      final url = await storageRef.getDownloadURL();
      print("Upload successful: $url");
      return url;
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }

  // Reviews Local Storage
  static Future<void> saveReviewLocal(UserReview review) async {
    final List<String> currentReviews = _prefs?.getStringList('kg_reviews') ?? [];
    currentReviews.add(jsonEncode(review.toJson()));
    await _prefs?.setStringList('kg_reviews', currentReviews);
  }

  static List<UserReview> loadReviewsLocal() {
    final data = _prefs?.getStringList('kg_reviews');
    if (data != null) {
      return data.map((e) => UserReview.fromJson(jsonDecode(e), '')).toList();
    }
    return [];
  }

  // Quests Persistence
  static Future<void> saveQuestsLocal(List<QuestModel> quests) async {
    final List<Map<String, dynamic>> data = quests.map((q) => {
      'id': q.id,
      'currentProgress': q.currentProgress,
      'isClaimed': q.isClaimed,
    }).toList();
    await _prefs?.setString(_questsKey, jsonEncode(data));
  }

  static List<Map<String, dynamic>>? loadQuestsLocal() {
    final data = _prefs?.getString(_questsKey);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return null;
  }

  // Zombie Game Persistence
  static Future<void> saveZombieStatsLocal(ZombieStats stats) async {
    await _prefs?.setString(_zombieKey, jsonEncode(stats.toJson()));
  }

  static ZombieStats? loadZombieStatsLocal() {
    final data = _prefs?.getString(_zombieKey);
    if (data != null) {
      return ZombieStats.fromJson(jsonDecode(data));
    }
    return null;
  }

  // Sky Rush Persistence
  static Future<void> saveSkyRushStatsLocal(SkyRushStats stats) async {
    await _prefs?.setString(_skyRushKey, jsonEncode(stats.toJson()));
  }

  static SkyRushStats? loadSkyRushStatsLocal() {
    final data = _prefs?.getString(_skyRushKey);
    if (data != null) {
      return SkyRushStats.fromJson(jsonDecode(data));
    }
    return null;
  }

  // Turbo Kart Persistence
  static Future<void> saveTurboKartStatsLocal(TurboKartStats stats) async {
    await _prefs?.setString(_turboKartKey, jsonEncode(stats.toJson()));
  }

  static TurboKartStats? loadTurboKartStatsLocal() {
    final data = _prefs?.getString(_turboKartKey);
    if (data != null) {
      return TurboKartStats.fromJson(jsonDecode(data));
    }
    return null;
  }
}
