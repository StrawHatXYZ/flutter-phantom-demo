import 'package:flutter/material.dart';
import 'package:flutter_phantom_demo/components/screens/screens.dart';
import 'package:flutter_phantom_demo/providers/screen_provider.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Sidebar extends StatelessWidget {
  final PhantomConnect phantomConnectInstance;
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const Sidebar({super.key, required this.phantomConnectInstance});
  @override
  Widget build(BuildContext context) {
    const solname = 'jhondoe.sol';
    var walletAddrs = phantomConnectInstance.userPublicKey;
    const urlImage = "https://picsum.photos/200/300";

    return Drawer(
      child: Material(
        color: const Color.fromRGBO(50, 75, 205, 1),
        child: ListView(
          children: <Widget>[
            buildHeader(
                urlImage: urlImage, name: solname, walletAddress: walletAddrs),
            const Divider(color: Colors.white70),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  buildSideBarButton(
                    text: 'Home',
                    icon: Icons.home,
                    onClicked: () =>
                        selectedItem(context, 0, phantomConnectInstance),
                  ),
                  const SizedBox(height: 16),
                  buildSideBarButton(
                    text: 'Sign Message',
                    icon: Icons.message,
                    onClicked: () =>
                        selectedItem(context, 1, phantomConnectInstance),
                  ),
                  const SizedBox(height: 16),
                  buildSideBarButton(
                    text: 'Sign and Send Transaction',
                    icon: Icons.send_and_archive,
                    onClicked: () =>
                        selectedItem(context, 2, phantomConnectInstance),
                  ),
                  const SizedBox(height: 16),
                  buildSideBarButton(
                    text: 'Sign Transaction',
                    icon: Icons.edit,
                    onClicked: () =>
                        selectedItem(context, 3, phantomConnectInstance),
                  ),
                  const SizedBox(height: 16),
                  buildSideBarButton(
                    text: 'Disconnect',
                    icon: Icons.link_off,
                    onClicked: () =>
                        selectedItem(context, 4, phantomConnectInstance),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white70),
                  const SizedBox(height: 24),
                  const _buildSocialWidgets()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String walletAddress,
  }) =>
      InkWell(
        child: Container(
          padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    toShortAddres(address: walletAddress),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                splashColor: Colors.white12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 0,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const Icon(Icons.copy, color: Colors.white),
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: walletAddress));
                },
              ),
            ],
          ),
        ),
      );

  String toShortAddres({required String address}) {
    return "${address.substring(0, 10)}...${address.substring(phantomConnectInstance.userPublicKey.length - 5, phantomConnectInstance.userPublicKey.length)}";
  }

  Widget buildSideBarButton({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index,
      PhantomConnect phantomConnectInstance) async {
    Navigator.pop(context);
    switch (index) {
      case 0:
        context.read<ScreenProvider>().changeScreen(Screens.home);
        break;
      case 1:
        context.read<ScreenProvider>().changeScreen(Screens.message);
        break;
      case 2:
        context.read<ScreenProvider>().changeScreen(Screens.send);
        break;
      case 3:
        context.read<ScreenProvider>().changeScreen(Screens.sign);
        break;
      case 4:
        Uri url = phantomConnectInstance.generateDisconnectUri(
            redirect: "/disconnect");
        await launchUrl(url, mode: LaunchMode.externalApplication);
        break;
      default:
        context.read<ScreenProvider>().changeScreen(Screens.home);
        break;
    }
  }
}

class _buildSocialWidgets extends StatelessWidget {
  const _buildSocialWidgets({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.twitter,
            color: Colors.white,
          ),
          onPressed: () => launchUrl(
            Uri.parse('https://twitter.com/strawhatxyz'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.github,
            color: Colors.white,
          ),
          onPressed: () => launchUrl(
            Uri.parse('https://github.com/Strawhatxyz/'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.globe,
            color: Colors.white,
          ),
          onPressed: () => launchUrl(
            Uri.parse('https://strawhat.xyz'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.envelope,
            color: Colors.white,
          ),
          onPressed: () => launchUrl(
            Uri.parse('mailto:hello@strawhat.xyz'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}
