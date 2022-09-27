import 'package:flutter/material.dart';
import 'package:flutter_phantom_demo/components/styled_text_feild.dart';
import 'package:flutter_phantom_demo/providers/wallet_state_provider.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:provider/provider.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:url_launcher/url_launcher.dart';

class SignAndSendTransactionScreen extends StatefulWidget {
  final PhantomConnect phantomConnectInstance;
  const SignAndSendTransactionScreen(
      {super.key, required this.phantomConnectInstance});

  @override
  State<SignAndSendTransactionScreen> createState() =>
      _SignAndSendTransactionScreenState();
}

class _SignAndSendTransactionScreenState
    extends State<SignAndSendTransactionScreen> {
  // User input
  TextEditingController walletAddressController = TextEditingController();
  TextEditingController solAmountController = TextEditingController();

  signAndSendTransaction(WalletStateProvider walletStateProvider) async {
    int amount =
        ((double.parse(solAmountController.text)) * lamportsPerSol).toInt();
    final transferIx = SystemInstruction.transfer(
        fundingAccount: Ed25519HDPublicKey.fromBase58(
            widget.phantomConnectInstance.userPublicKey),
        recipientAccount:
            Ed25519HDPublicKey.fromBase58(walletAddressController.text),
        lamports: amount);
    final message = Message.only(transferIx);
    final blockhash = await RpcClient('https://api.devnet.solana.com')
        .getRecentBlockhash()
        .then((b) => b.blockhash);
    final compiled = message.compile(recentBlockhash: blockhash);

    final tx = SignedTx(
      messageBytes: compiled.data,
      signatures: [
        Signature(
          List.filled(64, 0),
          publicKey: Ed25519HDPublicKey.fromBase58(
              widget.phantomConnectInstance.userPublicKey),
        )
      ],
    ).encode();

    var launchUri = widget.phantomConnectInstance
        .generateSignAndSendTransactionUri(
            transaction: tx, redirect: '/signAndSendTransaction');
    await launchUrl(
      launchUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState =
        Provider.of<WalletStateProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
          child: Column(
        children: [
          styledTextFeild(walletAddressController, "User Wallet Address",
              "Enter User wallet Address", Icons.wallet),
          const SizedBox(height: 10),
          styledTextFeild(solAmountController, "1 SOL = 1,000,000,000 LAMPORTS",
              "Enter amount to send in SOL", Icons.circle_outlined),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              signAndSendTransaction(walletState);
            },
            child: const Text("Sign and Send"),
          )
        ],
      )),
    );
  }
}
