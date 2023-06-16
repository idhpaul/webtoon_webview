// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

int _selectedIndex = 1; //New

void main() => runApp(const MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController controller;

  final enhanceTextFieldController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      //_selectedIndex = index;
      index == 0 ? _selectedIndex-- : _selectedIndex++;

      String uri =
          "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$_selectedIndex&weekday=tue";

      controller.loadRequest(Uri.parse(uri));
    });
  }

  void _chnagedIdx(int index) {
    setState(() {
      //_selectedIndex = index;
      _selectedIndex = index;

      String uri =
          "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$_selectedIndex&weekday=tue";

      controller.loadRequest(Uri.parse(uri));
    });
  }

  @override
  void initState() {
    super.initState();

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // max 1417
            if (request.url.startsWith(
                "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=1&weekday=tue")) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=1&weekday=tue"));
    // #enddocregion webview_controller
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Simple Example')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.navigate_before),
            label: 'before',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigate_next),
            label: 'next',
          ),
        ],
        currentIndex: 0, //New
        onTap: _onItemTapped, //New
      ),
      body:SafeArea( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color(0x1f000000),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextField(
                            controller: enhanceTextFieldController,
                            obscureText: false,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 14,
                              color: Color(0xff000000),
                            ),
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff000000), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff000000), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff000000), width: 1),
                              ),
                              hintText: "화 입력(최대 1417)",
                              hintStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff000000),
                              ),
                              filled: true,
                              fillColor: const Color(0xfff2f2f3),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: MaterialButton(
                        onPressed: () {
                          if (enhanceTextFieldController.text.isEmpty) {
                            showDialog(
                                context: context,
                                barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('에러'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: const <Widget>[
                                          Text('값을 입력하세요'),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('확인'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            int inputNum =
                                int.parse(enhanceTextFieldController.text);
                            if (0 < inputNum && inputNum <= 1417) {
                              _chnagedIdx(
                                  int.parse(enhanceTextFieldController.text));
                            } else {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('에러'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: const <Widget>[
                                            Text('범위내의 값을 입력하세요. (1~1417)'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('확인'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                        color: const Color(0xffffffff),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Color(0xff808080), width: 1),
                        ),
                        padding: const EdgeInsets.all(16),
                        textColor: const Color(0xff000000),
                        height: 40,
                        minWidth: 140,
                        child: const Text(
                          "이동",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xff808080),
              height: 16,
              thickness: 0,
              indent: 0,
              endIndent: 0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: WebViewWidget(controller: controller),
            )
          ])),
      
    );
  }
  // #enddocregion webview_widget
}
