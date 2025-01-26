import 'package:domashni_proekt/widgets/details/analysis_section.dart';
import 'package:domashni_proekt/widgets/details/graph_section.dart';
import 'package:domashni_proekt/widgets/details/stock_data_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/issuer.dart';
import '../providers/issuer_data_provider.dart';
import '../service/storage/firebase_cloud_storage.dart';
import '../service/storage/cloud_favorite.dart';

class DetailsScreen extends StatefulWidget {
  final Issuer issuer;

  const DetailsScreen({super.key, required this.issuer});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isFavorite = false;
  String? _favoriteId;
  final _storage = FirebaseCloudStorage();

  Future<void> _prepareData() async {
    await Provider.of<IssuerDataProvider>(context, listen: false)
        .fetchAnalysis(widget.issuer.symbol);

    await Provider.of<IssuerDataProvider>(context, listen: false)
        .fetchStocksData(widget.issuer.symbol);
  }

  @override
  void initState() {
    super.initState();
    _prepareData();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _storage.allFavorites(ownerUserId: userId).listen((favorites) {
      final favorite = favorites.firstWhere(
            (fav) => fav.symbol == widget.issuer.symbol,
        orElse: () => const CloudFavorite(id: '', ownerUserId: '', symbol: ''),
      );

      setState(() {
        _isFavorite = favorite.id.isNotEmpty;
        _favoriteId = favorite.id;
      });
    });
  }

  Future<void> _toggleFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    if (_isFavorite && _favoriteId != null) {
      await _storage.deleteNote(documentId: _favoriteId!);
      setState(() {
        _isFavorite = false;
        _favoriteId = null;
      });
    } else {
      final favorite = await _storage.createNewFavorite(
        userOwnerId: userId,
        symbol: widget.issuer.symbol,
      );
      setState(() {
        _isFavorite = true;
        _favoriteId = favorite.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final issuerData = Provider.of<IssuerDataProvider>(context).issuerData;

    if (issuerData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.issuer.symbol,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GraphSection(issuerData: issuerData),
            const SizedBox(height: 20),
            const AnalysisSection(),
            const SizedBox(height: 20),
            StockDataSection(issuerData: issuerData),
          ],
        ),
      ),
    );
  }
}