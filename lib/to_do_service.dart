import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ToDoService extends ChangeNotifier {
  final toDoCollection = FirebaseFirestore.instance.collection("toDo");

  // 읽기
  // QuerySnapshot : 파이어베이스에서 쿼리를 실행한 결과로 반환되는 객체
  // 퀴리결과로 반환된 여러 doc의 스냅샷을 가지고 있다.
  Future<QuerySnapshot> read(String uid) async {
    // 내 toDoList 가져오기
    return toDoCollection.where('uid', isEqualTo: uid).get();
  }

  // 쓰기
  void create(String job, String uid) async {
    // toDo 만들기
    await toDoCollection.add({
      'uid': uid,
      'job': job,
      'isDone': false,
    });
    notifyListeners();
  }

  // 변경
  void update(String docId, bool isDone) async {
    // toDo is Done update
    await toDoCollection.doc(docId).update({"isDone": isDone});
    notifyListeners();
  }

  // 삭제
  void delete(String docId) async {
    // toDo 삭제
    await toDoCollection.doc(docId).delete();
    notifyListeners();
  }
}
