import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domashni_proekt/service/storage/cloud_favorite.dart';

import 'cloud_storage_constants.dart';
import 'cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final favorites = FirebaseFirestore.instance.collection("favorites");

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();

  factory FirebaseCloudStorage() => _shared;

  Future<CloudFavorite> createNewFavorite(
      {required String userOwnerId, required String symbol}) async {
    final favorite = await favorites.add({
      ownerUserIdFieldName: userOwnerId,
      symbolName: symbol,
    });

    final fetchedFavorite = await favorite.get();
    return CloudFavorite(
      id: fetchedFavorite.id,
      ownerUserId: userOwnerId,
      symbol: symbol,
    );
  }

  Stream<Iterable<CloudFavorite>> allFavorites({required String ownerUserId}) {
    final allNotes = favorites
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((e) => e.docs.map((doc) => CloudFavorite.fromSnapshot(doc)));
    return allNotes;
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await favorites.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
