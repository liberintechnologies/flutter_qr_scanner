import 'package:example/history/model.dart';
import 'package:example/history/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.sharedPrefs});

  final SharedPrefs sharedPrefs;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BarcodeModel>? savedBarcodeList = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("History will be cleared!"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                widget.sharedPrefs.clearSharedPref();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("Delete"))
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: widget.sharedPrefs.getbarcodeDataList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final list = snapshot.data as List<BarcodeModel>;

              return list.isEmpty
                  ? const Center(
                      child: Text("No data found!"),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 2.0,
                        );
                      },
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Type: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                            text: list[index].type,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Format: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                            text: list[index].format,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      Text(
                                        "Display value: ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SelectableLinkify(
                                        text: list[index].displayValue,
                                        onOpen: (link) async {
                                          String url = link.url;
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Could not launch url");
                                          }
                                        },
                                        linkStyle:
                                            TextStyle(color: Colors.blue[400]),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        );
                      },
                    );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }

  // void getBarCodeDataFromSharedPreference() {
  //   savedBarcodeList = widget.sharedPrefs.getbarcodeDataList();
  // }
}
