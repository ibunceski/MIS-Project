import 'package:domashni_proekt/model/issuer.dart';
import 'package:domashni_proekt/providers/issuer_data_provider.dart';
import 'package:domashni_proekt/service/api/api_service.dart';
import 'package:domashni_proekt/widgets/search/custom_search_field.dart';
import 'package:domashni_proekt/widgets/search/header_section.dart';
import 'package:domashni_proekt/widgets/search/loading_dialog.dart';
import 'package:domashni_proekt/widgets/search/search_section.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;
  List<Issuer> _issuers = [];

  @override
  void initState() {
    super.initState();
    _fetchIssuers();
    _clearIssuerData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _clearIssuerData();
  }

  Future<void> _fetchIssuers() async {
    try {
      final List<dynamic> data = json.decode(await ApiService.getIssuers());
      setState(() {
        _issuers = data.map((json) => Issuer.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error fetching issuers: $e');
    }
  }

  void _clearIssuerData() {
    Provider.of<IssuerDataProvider>(context, listen: false).clearData();
    print(Provider.of<IssuerDataProvider>(context, listen: false).issuerData);
  }

  Future<void> _updateData() async {
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingDialog(),
    );
    try {
      await ApiService.fillData();
      await _fetchIssuers();
    } catch (e) {
      print('Error updating data: $e');
    }
    if (mounted) {
      Navigator.of(context).pop();
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Macedonian Market Pulse',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.update, color: Colors.white),
            onPressed: _updateData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const HeaderSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SearchSection(),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomSearchField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onSelected: (issuer) {
                                _clearIssuerData();
                                Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: issuer,
                                );
                              },
                              issuers: _issuers,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'account_fab',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/account',
              );
            },
            backgroundColor: Colors.blue.shade700,
            mini: true,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'favorites_fab',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/favorites',
              );
            },
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.star, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
