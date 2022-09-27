import 'package:flutter/material.dart';
import 'package:flutter_phantom_demo/utils/logger.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:url_launcher/url_launcher.dart';

class NotConnected extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const NotConnected({super.key, required this.phantomConnectInstance});

  @override
  State<NotConnected> createState() => _NotConnectedState();
}

class _NotConnectedState extends State<NotConnected> {
  connectWallet() async {
    Uri launchUri = widget.phantomConnectInstance
        .generateConnectUri(cluster: 'devnet', redirect: '/connected');
    logger.d(launchUri);
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Flutter Solana \n Phantom Demo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            onPressed: connectWallet,
            label: const Text("Connect Wallet"),
            icon: const Icon(Icons.link),
            style: ElevatedButton.styleFrom(
              elevation: 4,
            ),
          )
        ],
      ),
    );
  }
}
