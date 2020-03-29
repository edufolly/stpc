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
  final Map<String, dynamic> packs = {};
  StreamController<bool> _streamController;
  SharedPreferences prefs;

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
    prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = await MetricHttpClient.doCall(
      endpoint: '/users/5e80b4d432c450583d46076e/tags?limit=9999',
    );

    List tags = json.decode(data['body']);

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

          packs[packName]['open'] = prefs.containsKey(packs[packName]['id'])
              ? prefs.getBool(packs[packName]['id'])
              : false;
        }
      }
    } catch (exception) {
      print(exception);
    }

    packs[lastPack] = {
      'id': lastPack,
      'name': 'Other Tags',
      'tags': emptyPack,
      'open': false,
    };

    // TODO - Continue...

    print('Packs: $packs');

    _streamController.add(true);
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
              child: StreamBuilder<bool>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data) {
                      List<String> keys = packs.keys.toList();
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          Map<String, dynamic> pack = packs[keys[index]];
                          return ListTile(
                            leading: Icon(pack['open']
                                ? Icons.keyboard_arrow_down
                                : Icons.chevron_right),
                            title: Text(pack['name'] ?? 'ERROR'),
                            subtitle: pack['open'] ? Text(pack['id']) : null,
                            onTap: () {
                              pack['open'] = !pack['open'];
                              prefs.setBool(pack['id'], pack['open']);
                              _streamController.add(true);
                            },
                          );
                        },
                        separatorBuilder: (context, index) => Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.black26,
                        ),
                        itemCount: keys.length,
                      );
                    }
                  }

                  return WaitingMessage('Aguarde...');
                },
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
