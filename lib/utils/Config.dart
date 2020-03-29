///
///
///
class Config {
  static final Config _singleton = Config._internal();

  ///
  ///
  ///
  factory Config() {
    return _singleton;
  }

  bool debug = false;
  String parser = 'https://www.strategiccore.com.br/api/v3/cors';
  String endpoint = 'https://tagpacker.com/api';
//  String apiKey;
  String userName;
  String userId;
  String name;
  String photoUrl;

  ///
  ///
  ///
  Config._internal();
}
