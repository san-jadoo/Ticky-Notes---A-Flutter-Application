import 'package:cloud_firestore/cloud_firestore.dart';

class Tickynotes {
  final String id;
  final String title;
  final String desc;
  final bool isCompleted;
  final Timestamp timeStamp;

  Tickynotes({
    required this.id,
    required this.title,
    required this.desc,
    required this.isCompleted,
    required this.timeStamp,
  });
}
