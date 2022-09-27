import 'package:flutter/material.dart';
import 'package:flutter_phantom_demo/utils/helpers.dart';
import 'package:flutter_phantom_demo/utils/logger.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionStatus extends StatefulWidget {
  final String signature;
  const TransactionStatus({super.key, required this.signature});

  @override
  State<TransactionStatus> createState() => _TransactionStatusState();
}

class _TransactionStatusState extends State<TransactionStatus> {
  //
  SignatureStatus? _transactionStatus;
  bool isConfirmed = false;

  RpcClient rpcClient = RpcClient("https://api.devnet.solana.com");
  TextStyle textStyle = const TextStyle(
      color: Colors.blue, fontSize: 22, fontWeight: FontWeight.w900);

  getTransactionStatus() async {
    logger.wtf("Hello Status ${widget.signature}");
    while (!isConfirmed) {
      List<SignatureStatus?> status =
          await rpcClient.getSignatureStatuses([widget.signature]);

      try {
        logger.e(status);
        setState(() {
          _transactionStatus = status[0]!;
        });
        logger.i(_transactionStatus?.confirmations);
        logger.i(_transactionStatus?.confirmationStatus);

        if (_transactionStatus?.confirmationStatus == Commitment.finalized) {
          setState(() {
            isConfirmed = true;
            return;
          });
        }
      } catch (e) {
        logger.e(e);
      }
      await delay(100);
    }
  }

  @override
  void initState() {
    getTransactionStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signature Status'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: !isConfirmed
              ? [
                  Text(
                    "Confirmations: ${_transactionStatus?.confirmations ?? 0}",
                    style: textStyle,
                  ),
                ]
              : [
                  Text(
                    "Status: ${_transactionStatus?.confirmationStatus}",
                    style: textStyle,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      launchUrl(
                          Uri.parse(
                              "https://explorer.solana.com/tx/${widget.signature}?cluster=devnet"),
                          mode: LaunchMode.externalApplication);
                    },
                    child: const Text("View it on Solana Explorer"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
                  ),
                ],
        ),
      ),
    );
  }
}
