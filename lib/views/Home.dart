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
      endpoint: '/users/${_config.userId}/links?limit=9999',
      log: false,
    );

    List links = json.decode(data['body']);

    List<Map<String, dynamic>> linksWithoutTag = [];

    List<Map<String, dynamic>> tagsWithoutPack = [];

    Map<String, dynamic> tags = {};

    try {
      for (Map<String, dynamic> link in links) {
        List internalTags = link.remove('tags');
        if (internalTags == null || internalTags.isEmpty) {
          linksWithoutTag.add(link);
        } else {
          for (Map<String, dynamic> tag in internalTags) {
            String tagName = tag['name'];
            if (!tags.containsKey(tagName)) {
              tag['links'] = [];
              tags[tagName] = tag;
            }
            tags[tagName]['links'].add(link);

            tags[tagName]['open'] = prefs.containsKey(tags[tagName]['id'])
                ? prefs.getBool(tags[tagName]['id'])
                : false;
          }
        }
      }

      for (String key in tags.keys) {
        Map<String, dynamic> tag = tags[key];
        Map<String, dynamic> pack = tag.remove('pack');
        if (pack == null) {
          tagsWithoutPack.add(tag);
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
      'id': 'pack_$lastPack',
      'name': 'Other Tags',
      'tags': tagsWithoutPack,
      'open': false,
    };

//    print('Packs: $packs');

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
                            leading: Icon(
                              pack['open']
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                            ),
                            title: Padding(
                              padding: EdgeInsets.only(
                                top: pack['open'] ? 16.0 : 0.0,
                              ),
                              child: Text(pack['name'] ?? 'ERROR'),
                            ),
                            subtitle:
                                pack['open'] ? _getTags(pack['tags']) : null,
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
  Widget _getTags(List tags) {
    return Column(
      children: tags.map(
        (tag) {
          return ListTile(
            leading: Icon(
              tag['open']
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
            ),
            title: Padding(
              padding: EdgeInsets.only(
                top: tag['open'] ? 16.0 : 0.0,
              ),
              child: Text(tag['name']),
            ),
            subtitle: tag['open'] ? _getLinks(tag['links']) : null,
            onTap: () {
              tag['open'] = !tag['open'];
              prefs.setBool(tag['id'], tag['open']);
              _streamController.add(true);
            },
          );
        },
      ).toList(),
    );
  }

  ///
  ///
  ///
  Widget _getLinks(List links) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links
            .map(
              (link) => ListTile(
                leading: Icon(Icons.link),
                title: Text(link['title']),
                onTap: () => print(link['sourceUrl']),
              ),
            )
            .toList(),
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
