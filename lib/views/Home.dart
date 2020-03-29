import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpc/utils/Config.dart';
import 'package:stpc/utils/MetricHttpClient.dart';
import 'package:stpc/utils/WaitingMessage.dart';

import 'Login.dart';

final String lastPack = 'ZZZZZZZZZZ';

///
///
///
class Home extends StatefulWidget {
  ///
  ///
  ///
  @override
  _HomeState createState() => _HomeState();
}

///
///
///
class _HomeState extends State<Home> {
  final Config _config = Config();
  StreamController<Map<String, dynamic>> _streamController;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _loadData();
  }

  ///
  ///
  ///
  void _loadData() async {
    Map<String, dynamic> data = await MetricHttpClient.doCall(
        endpoint: '/users/5e80b4d432c450583d46076e/tags?limit=9999');

    List tags = List.from(json.decode(data['body']));

    print('Tags: ${tags.length}');

    Map<String, dynamic> packs = {};

    List<Map<String, dynamic>> emptyPack = [];

    try {
      for (Map<String, dynamic> tag in tags) {
        Map<String, dynamic> pack = tag.remove('pack');
        if (pack == null) {
          emptyPack.add(tag);
        } else {
          String packName = pack['name'];
          if (!packs.containsKey(packName)) {
            pack['tags'] = [];
            packs[packName] = pack;
          }
          packs[packName]['tags'].add(tag);
        }
      }
    } catch (exception) {
      print(exception);
    }

    packs[lastPack] = {
      'name': lastPack,
      'tags': emptyPack,
    };

    print('Packs: $packs');

    _streamController.add(packs);
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_config.name),
            ],
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _singOut,
          )
        ],
      ),
      body: Row(
        children: <Widget>[
          Flexible(
            child: Container(),
          ),
          Container(
            width: MediaQuery.of(context).size.width > 1000
                ? 1000
                : MediaQuery.of(context).size.width,
            height: double.infinity,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<Map<String, dynamic>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> packs = snapshot.data;

                      return Text('Packs: ${packs.length}');
                    }

                    return WaitingMessage('Aguarde...');
                  },
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(),
          ),
        ],
      ),
    );
  }

  ///
  ///
  ///
  void _singOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
      (_) => false,
    );
  }

  ///
  ///
  ///
  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
