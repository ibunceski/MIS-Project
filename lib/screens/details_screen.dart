// import 'package:domashni_proekt/providers/issuer_data_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../model/issuer.dart';
// import '../widgets/historic_graph.dart';
// import '../widgets/stock_table.dart';
// import 'fundamental_analysis_screen.dart';
// import 'lstm_analysis_screen.dart';
// import 'technical_analysis_screen.dart';
//
// class DetailsScreen extends StatefulWidget {
//   final Issuer issuer;
//
//   const DetailsScreen({super.key, required this.issuer});
//
//   @override
//   State<DetailsScreen> createState() => _DetailsScreenState();
// }
//
// class _DetailsScreenState extends State<DetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final issuerData = Provider.of<IssuerDataProvider>(context).issuerData;
//
//     if (issuerData.isEmpty) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.issuer.symbol),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const Text(
//               'Graph',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 5, 20, 10),
//                 child: PriceChart(jsonData: issuerData)),
//             const SizedBox(height: 20),
//             const Text(
//               'Analysis',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Technical Analysis Box
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               const TechnicalAnalysisScreen()),
//                     );
//                   },
//                   child: Container(
//                     width: 100, // Adjust width as needed
//                     padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.blue),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Technical',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // LSTM Analysis Box
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const LSTMAnalysisScreen()),
//                     );
//                   },
//                   child: Container(
//                     width: 100, // Adjust width as needed
//                     padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'LSTM',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Fundamental Analysis Box
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               const FundamentalAnalysisScreen()),
//                     );
//                   },
//                   child: Container(
//                     width: 100, // Adjust width as needed
//                     padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.orange),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Fundamental',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Stock Historic Data',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             StockDataTable(jsonData: issuerData),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/issuer.dart';
import '../widgets/historic_graph.dart';
import '../widgets/stock_table.dart';
import '../service/storage/firebase_cloud_storage.dart';
import '../service/storage/cloud_favorite.dart';
import 'fundamental_analysis_screen.dart';
import 'lstm_analysis_screen.dart';
import 'technical_analysis_screen.dart';

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
      appBar: AppBar(
        title: Text(widget.issuer.symbol),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              color: _isFavorite ? Colors.yellow : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Graph',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 20, 10),
                child: PriceChart(jsonData: issuerData)),
            const SizedBox(height: 20),
            const Text(
              'Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Technical Analysis Box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const TechnicalAnalysisScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Center(
                      child: Text(
                        'Technical',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                // LSTM Analysis Box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LSTMAnalysisScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Center(
                      child: Text(
                        'LSTM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                // Fundamental Analysis Box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const FundamentalAnalysisScreen()),
                    );
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Center(
                      child: Text(
                        'Fundamental',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Stock Historic Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StockDataTable(jsonData: issuerData),
          ],
        ),
      ),
    );
  }
}
