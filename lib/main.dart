// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(home: WebViewExample()));
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;

  bool _isChecked = false;

  late final WebViewController controller;
  final enhanceTextFieldController = TextEditingController();

  void tt() async {
    Uri uri = Uri.parse(
        "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=1&weekday=tue");
    print(uri);

    Map<String, String> header = {
      'Accept': 'text/html',
    };

    try {
      final response = await get(
        uri,
        headers: header,
      );

      if (response.statusCode != 200)
        throw HttpException('${response.statusCode} / ${response.body}');

      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      print(decodedResponse);

      //var expireDateTime = HttpDate.parse(response.headers['date']!).add(Duration(seconds: decodedResponse['expires_in']));
      //print("토큰 만료일(GST, KST) : ${expireDateTime.millisecondsSinceEpoch}, ${expireDateTime.toLocal()}");
      // var expireTimeStamp = (expireDateTime.millisecondsSinceEpoch + DateTime.now().timeZoneOffset.inMilliseconds);
      // print(expireTimeStamp);
    } on SocketException {
      print('No Internet connection 😑');
    } on HttpException catch (e) {
      print("Couldn't find the get 😱/n ${e.message}");
    } catch (e) {
      print("Couldn't find the get 😱/n $e");
    }
  }

  void loadRequest(String uri) {
    controller.loadRequest(Uri.parse(uri));
  }

  Future<void> _incrementIdx() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('pageIndex') ?? 1) + 1;

    setState(() {
      _counter = prefs.setInt('pageIndex', counter).then((bool success) {
        enhanceTextFieldController.text = counter.toString();
        loadRequest(
            "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$counter&weekday=tue");

        return counter;
      });
    });
  }

  Future<void> _decrementIdx() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('pageIndex') ?? 1) - 1;

    setState(() {
      _counter = prefs.setInt('pageIndex', counter).then((bool success) {
        enhanceTextFieldController.text = counter.toString();
        loadRequest(
            "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$counter&weekday=tue");

        return counter;
      });
    });
  }

  Future<void> _changeIdx(int idx) async {
    final SharedPreferences prefs = await _prefs;
    final int counter = idx;

    setState(() {
      _counter = prefs.setInt('pageIndex', counter).then((bool success) {
        enhanceTextFieldController.text = counter.toString();
        loadRequest(
            "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$counter&weekday=tue");

        return counter;
      });
    });
  }

  Future<void> _getIdx() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('pageIndex') ?? 1);

    setState(() {
      _counter = prefs.setInt('counter', counter).then((bool success) {
        enhanceTextFieldController.text = counter.toString();
        loadRequest(
            "https://archive.is/https://comic.naver.com/webtoon/detail.nhn?titleId=119874&no=$counter&weekday=tue");

        return counter;
      });
    });
  }

  void _onItemTapped(int index) {
    index == 0 ? _decrementIdx() : _incrementIdx();
  }

  void _chnagedIdx(int index) {
    _changeIdx(index);
  }

  void readResponse() async {
    var html = controller.runJavaScriptReturningResult(
        "document.getElementsByClassName('THUMBS-BLOCK')[0].getElementsByTagName('a')[0].href;");
    html.then((value) {
      print(value);
      if (value != "null") {
        String result = (value as String).replaceAll(RegExp('"'), "");
        controller.loadRequest(Uri.parse(result));
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('종료'),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('종료하시겠습니까?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('취소'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('종료'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ))) ??
        false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            if (_isChecked) {
              readResponse();
            }
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      );
    _getIdx();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.navigate_before),
              label: 'Before',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.navigate_next),
              label: 'Next',
            ),
          ],
          onTap: _onItemTapped, //New
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
        ),
        body: WillPopScope(
            onWillPop: _onWillPop,
            child: SafeArea(
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
                      border:
                          Border.all(color: const Color(0x4d9e9e9e), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 3,
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
                                    hintText: "(최대 1417)",
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
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: MaterialButton(
                              onPressed: () {
                                if (enhanceTextFieldController.text.isEmpty) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible:
                                          true, // 바깥 영역 터치시 닫을지 여부
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('에러'),
                                          content: const SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
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
                                  int inputNum = int.parse(
                                      enhanceTextFieldController.text);
                                  if (0 < inputNum && inputNum <= 1417) {
                                    _chnagedIdx(int.parse(
                                        enhanceTextFieldController.text));
                                  } else {
                                    showDialog(
                                        context: context,
                                        barrierDismissible:
                                            true, // 바깥 영역 터치시 닫을지 여부
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('에러'),
                                            content:
                                                const SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                      '범위내의 값을 입력하세요. (1~1417)'),
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
                                side: BorderSide(
                                    color: Color(0xff808080), width: 1),
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
                        Expanded(
                          flex: 1,
                          child: Switch(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value;
                              });
                            },
                          ),
                        )
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
                ]))));
  }
  // #enddocregion webview_widget
}
