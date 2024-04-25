import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String uid;
  final String? userType;
  final String? name;
  final String? school;
  final String? major;
  final String? bio;
  final String profilePictureUrl;

  UserProfile({
    required this.email,
    required this.userType,
    required this.uid,
    this.name,
    this.school,
    this.major,
    this.bio,
    this.profilePictureUrl = 'https://64.media.tumblr.com/0a049264fba0072a818f733a6c533578/tumblr_mqvlz4t5FK1qcnibxo1_540.png', 
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
      'name': name,
      'school': school,
      'major': major,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}