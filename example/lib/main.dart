import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_qr/quick_qr.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr code scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Qr code scanner Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _qrCodeData = "";
  String? _qrCodeFormat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _qrCodeData.isEmpty ? 'Qr code data will be shown here.' : "",
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: _qrCodeData.isNotEmpty,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Qr code format: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "$_qrCodeFormat")
                  ]))),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Linkify(
                text: _qrCodeData,
                onOpen: (link) async {
                  String url = link.url;
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Fluttertoast.showToast(msg: "Could not launch url");
                  }
                },
                linkStyle: TextStyle(color: Colors.blue[400]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (mounted) {
              setState(() {
                _qrCodeData = "";
                _qrCodeFormat = "";
              });
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                maintainState: false,
                builder: (context) {
                  return CameraSource(
                    immersive: false,
                    stopOnFound: true,
                    onDetect: (barcode) async {
                      // debugPrint("value: ${barcode.value}", wrapWidth: 1024);
                      // debugPrint("type: ${barcode.type}", wrapWidth: 1024);
                      // debugPrint("raw: ${barcode.rawValue}", wrapWidth: 1024);
                      // debugPrint("bytes: ${barcode.rawBytes}", wrapWidth: 1024);
                      // debugPrint("format: ${barcode.format}", wrapWidth: 1024);
                      // debugPrint("display: ${barcode.displayValue}",
                      //     wrapWidth: 1024);

                      if (mounted) {
                        setState(() {
                          _qrCodeData = barcode.displayValue!;
                          _qrCodeFormat = barcode.format.name;
                        });
                      }

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
          tooltip: 'Open QrCode scanner',
          child: const Icon(Icons
              .qr_code)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
