import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/kids_models.dart';

class StorageService {
  static const String _userKey = 'kg_user_data';
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
      final storageRef = FirebaseStorage.instance.ref().child('profile_pics').child('$uid.jpg');
      
      if (kIsWeb) {
        // dynamic imageFile is Uint8List for Web
        await storageRef.putData(imageFile);
      } else {
        // dynamic imageFile is File for Mobile
        await storageRef.putFile(imageFile as File);
      }
      
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Image Upload Error: $e");
      return null;
    }
  }
}
