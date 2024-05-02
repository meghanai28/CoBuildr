import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String uid;
  final String? userType;
  final String? name;
  final String? school;
  final String? major;
  final String? bio;
  final String? skills;
  final String profilePictureUrl;
  final List? seenProjects;
  final List? likedProjects;
  final List? advisorRequests;

  UserProfile({
    required this.email,
    required this.userType,
    required this.uid,
    this.name,
    this.school,
    this.major,
    this.bio,
    this.skills,
    this.seenProjects,
    this.likedProjects,
    this.advisorRequests,
    this.profilePictureUrl = 'https://tse1.mm.bing.net/th?q=blank%20pfp%20icon', 
    
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
      'seenProjects': seenProjects,
      'skills': skills,
      'likedProjects': likedProjects,
      'advisorRequests': advisorRequests,
    };
  }
}