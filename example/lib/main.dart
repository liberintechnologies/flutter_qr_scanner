import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scanner/qr_scanner.dart';
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
      title: 'Qr code scanner Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                maintainState: false,
                builder: (context) {
                  return CameraSource(
                    immersive: false,
                    stopOnFound: true,
                    onDetect: (barcode) async {
                      debugPrint("value: ${barcode.value}", wrapWidth: 1024);
                      debugPrint("type: ${barcode.type}", wrapWidth: 1024);
                      debugPrint("raw: ${barcode.rawValue}", wrapWidth: 1024);
                      debugPrint("bytes: ${barcode.rawBytes}", wrapWidth: 1024);
                      debugPrint("format: ${barcode.format}", wrapWidth: 1024);
                      debugPrint("display: ${barcode.displayValue}",
                          wrapWidth: 1024);

                      setState(() {
                        _qrCodeData = barcode.displayValue!;
                      });

                      Navigator.pop(context);

                      // barcode.value = A barcode value depending on the [BarcodeType] type set.
                      // barcode.type = The format type of the barcode.
                      // barcode.rawValue = A barcode value as it was encoded in the barcode.
                      // barcode.rawBytes = Barcode bytes as encoded in the barcode.
                      // barcode.format = The format (symbology) of the barcode value.
                      // barcode.displayValue = A barcode value in a user-friendly format. This value may be multiline, for example, when line breaks are encoded into the original TEXT barcode value. May include the supplement value.
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
