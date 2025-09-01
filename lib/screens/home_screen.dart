import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'menu/menu_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('SmartMenu',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => QRScannerScreen())),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('SCANNER QR RESTAURANT'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MenuScreen())),
              child: const Text('Demo: Pizza Power'),
            ),
          ],
        ),
      ),
    );
  }
}
