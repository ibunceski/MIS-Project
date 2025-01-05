import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudFavorite {
  final String id;
  final String ownerUserId;
  final String symbol;

  const CloudFavorite({
    required this.id,
    required this.ownerUserId,
    required this.symbol,
  });

  CloudFavorite.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        symbol = snapshot.data()[symbolName] as String;
}
