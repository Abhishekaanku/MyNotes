import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learn_dart/constants/firestore_contants.dart';
import 'package:learn_dart/exception/firestore_exceptions.dart';
import 'package:learn_dart/service/auth_service.dart';

class CloudStoreService {
  final notesStore = FirebaseFirestore.instance.collection(notesCollectionName);

  static final CloudStoreService _instance = CloudStoreService._singleton();
  CloudStoreService._singleton();
  factory CloudStoreService() => _instance;

  Stream<Iterable<CloudNote>> userNotes(String userId) =>
      notesStore.snapshots().map(
            (event) => event.docs
                .map(
                  (doc) => CloudNote.fromQueryDocSnapshot(doc),
                )
                .where(
                  (doc) => doc.userId == userId,
                ),
          );

  Future<Iterable<CloudNote>> getUserNotes(String userId) async {
    try {
      final querySnapshot = await notesStore
          .where(
            notesUserIdFieldName,
            isEqualTo: userId,
          )
          .get();
      return querySnapshot.docs.map(
        (doc) => CloudNote.fromQueryDocSnapshot(doc),
      );
    } catch (e) {
      throw ReadCloudStoreException();
    }
  }

  Future<CloudNote> createNotes(AuthUser owner) async {
    try {
      var doc = await notesStore.add({
        notesTextFieldName: "",
        notesUserIdFieldName: owner.userId,
      });
      return doc.get().then(
            (value) => CloudNote.fromDocSnapshot(value),
          );
    } catch (e) {
      throw CreateCloudStoreException();
    }
  }

  Future<void> deleteNote(String notesId) async {
    try {
      notesStore.doc(notesId).delete();
    } catch (e) {
      throw DeleteCloudStoreException();
    }
  }

  void deleteNotesForUser(AuthUser authUser) async {
    try {
      final querySnapshot = await notesStore
          .where(
            notesUserIdFieldName,
            isEqualTo: authUser.userId,
          )
          .get();
      for (var element in querySnapshot.docs) {
        deleteNote(element.id);
      }
    } catch (e) {
      throw DeleteCloudStoreException();
    }
  }

  Future<CloudNote> updateNote(String notesId, String text) async {
    try {
      await notesStore.doc(notesId).update({
        notesTextFieldName: text,
      });
      return CloudNote.fromDocSnapshot(await notesStore.doc(notesId).get());
    } catch (e) {
      throw UpdateCloudStoreException();
    }
  }

  Future<void> getOrCreateUser() {
    return Future.delayed(const Duration(milliseconds: 10));
  }
}

class CloudNote {
  final String notesId;
  final String text;
  final String userId;

  CloudNote({
    required this.notesId,
    required this.text,
    required this.userId,
  });

  CloudNote.fromQueryDocSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> q)
      : notesId = q.id,
        text = q.data()[notesTextFieldName] as String,
        userId = q.data()[notesUserIdFieldName] as String;

  CloudNote.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>> q)
      : notesId = q.id,
        text = q.get(notesTextFieldName),
        userId = q.get(notesUserIdFieldName);

  @override
  bool operator ==(covariant CloudNote other) => notesId == other.notesId;

  @override
  int get hashCode => notesId.hashCode;

  @override
  String toString() =>
      "CloudNote: notesId $notesId, userId: $userId, text: $text";
}
