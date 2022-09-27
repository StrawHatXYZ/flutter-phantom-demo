import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phantom_demo/components/connected/connected.dart';
import 'package:flutter_phantom_demo/components/not_connected/not_connected.dart';
import 'package:flutter_phantom_demo/components/screens/sign_in_message/signature_verify.dart';
import 'package:flutter_phantom_demo/components/screens/sign_transaction/send_transaction.dart';
import 'package:flutter_phantom_demo/components/screens/transaction_status.dart';
import 'package:flutter_phantom_demo/components/sidebar/sidebar.dart';
import 'package:flutter_phantom_demo/providers/wallet_state_provider.dart';
import 'package:flutter_phantom_demo/utils/logger.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final phantomConnectInstance = PhantomConnect(
    appUrl: "https://solgallery.vercel.app",
    deepLink: "dapp://phantomconnect.io",
  );
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks(context);
  }

  @override
  void dispose() {
    logger.w("Dispose");
    super.dispose();
    sub.cancel();
  }

  void _handleIncomingLinks(context) async {
    final provider = Provider.of<WalletStateProvider>(context, listen: false);
    try {
      sub = uriLinkStream.listen((Uri? link) {
        if (!mounted) return;
        Map<String, String> params = link?.queryParameters ?? {};
        logger.i("Params: $params");
        if (params.containsKey("errorCode")) {
          _showSnackBar(context,
              params["errorMessage"] ?? "Error connecting wallet", "error");
          logger.e(params["errorMessage"]);
        } else {
          switch (link?.path) {
            case '/connected':
              if (phantomConnectInstance.createSession(params)) {
                provider.updateConnection(true);
                _showSnackBar(context, "Connected to Wallet", "success");
              } else {
                _showSnackBar(context, "Error connecting to Wallet", "error");
              }
              break;
            case '/disconnect':
              setState(() {
                provider.updateConnection(false);
              });
              _showSnackBar(context, "Wallet Disconnected", "success");
              break;
            case '/signAndSendTransaction':
              var data = phantomConnectInstance.decryptPayload(
                  data: params["data"]!, nonce: params["nonce"]!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionStatus(
                    signature: data['signature'],
                  ),
                ),
              );
              break;
            case '/signTransaction':
              var data = phantomConnectInstance.decryptPayload(
                  data: params["data"]!, nonce: params["nonce"]!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendTxScreen(
                    transaction: data["transaction"],
                  ),
                ),
              );
              break;
            case '/onSignMessage':
              var data = phantomConnectInstance.decryptPayload(
                  data: params["data"]!, nonce: params["nonce"]!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignatureVerifyScreen(
                    signature: data['signature'],
                    phantomConnectInstance: phantomConnectInstance,
                  ),
                ),
              );
              break;
            default:
              logger.i('unknown');
              _showSnackBar(context, "Unknown Redirect", "error");
          }
        }
      }, onError: (err) {
        logger.e('OnError Error: $err');
      });
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      logger.e("Error occured PlatfotmException");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletStateProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Welcome to Flutter Demo App"),
      ),
      drawer: provider.isConnected
          ? Sidebar(phantomConnectInstance: phantomConnectInstance)
          : null,
      body: Builder(builder: (context) {
        return provider.isConnected
            ? Connected(phantomConnectInstance: phantomConnectInstance)
            : NotConnected(phantomConnectInstance: phantomConnectInstance);
      }),
    );
  }
}

_showSnackBar(BuildContext context, String message, String variant) {
  Color backgroundColor = Colors.blueAccent;
  if (variant == 'error') {
    backgroundColor = Colors.red.shade400;
  } else if (variant == 'success') {
    backgroundColor = Colors.green.shade500;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 5),
      backgroundColor: backgroundColor,
      content: Text(message),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
