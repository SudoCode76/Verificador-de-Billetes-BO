import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../scanner/scanner_page.dart';
import 'terms_page.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  static const _acceptedKey = 'termsAccepted';
  bool? _isAccepted;

  @override
  void initState() {
    super.initState();
    _loadAcceptance();
  }

  Future<void> _loadAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _isAccepted = prefs.getBool(_acceptedKey) ?? false);
    }
  }

  Future<void> _markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acceptedKey, true);
    if (mounted) {
      setState(() => _isAccepted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAccepted == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1A12),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAccepted == true) {
      return const ScannerPage();
    }

    return TermsPage(onAccepted: _markAccepted);
  }
}
