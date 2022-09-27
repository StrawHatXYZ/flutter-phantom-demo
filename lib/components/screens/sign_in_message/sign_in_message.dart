import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phantom_demo/providers/wallet_state_provider.dart';
import 'package:flutter_phantom_demo/utils/logger.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

//https://github.com/ilap/pinenacl-dart/blob/master/example/signature.dart

class SignInMessageScreen extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const SignInMessageScreen({super.key, required this.phantomConnectInstance});

  @override
  State<SignInMessageScreen> createState() => _SignInMessageScreenState();
}

class _SignInMessageScreenState extends State<SignInMessageScreen> {
  _signInAUth(WalletStateProvider walletState) async {
    Uint8List nonce = walletState.generateNoce();
    Uri launchUri = widget.phantomConnectInstance
        .generateSignMessageUri(nonce: nonce, redirect: '/onSignMessage');
    logger.i(launchUri);
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState =
        Provider.of<WalletStateProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Once app is connected to Phantom, we can request that the user signs a given message.\nMessage signatures do not involve network fees and are a convenient way for apps to verify ownership of an address.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                _signInAUth(walletState);
              },
              child: const Text("Sign Message"),
            ),
          ],
        ),
      ),
    );
  }
}
