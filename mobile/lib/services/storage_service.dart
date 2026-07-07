import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get token => _prefs.getString('token');
  set token(String? value) {
    if (value != null) {
      _prefs.setString('token', value);
    } else {
      _prefs.remove('token');
    }
  }

  String? get userId => _prefs.getString('user_id');
  set userId(String? value) {
    if (value != null) {
      _prefs.setString('user_id', value);
    } else {
      _prefs.remove('user_id');
    }
  }

  String? get userData => _prefs.getString('user_data');
  set userData(String? value) {
    if (value != null) {
      _prefs.setString('user_data', value);
    } else {
      _prefs.remove('user_data');
    }
  }

  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;
  set isDarkMode(bool value) => _prefs.setBool('dark_mode', value);

  String? get selectedCountry => _prefs.getString('selected_country');
  set selectedCountry(String? value) {
    if (value != null) {
      _prefs.setString('selected_country', value);
    }
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
