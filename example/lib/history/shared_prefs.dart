
import 'package:example/history/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPreferences;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setBarcodeData(String key, String data) async {
    await _sharedPreferences.setString(key, data);
  }

  Future<List<BarcodeModel>> getbarcodeDataList() async {
    List<BarcodeModel> dataList = [];
    final getKeys = _sharedPreferences.getKeys().toList();
    for (int i = 0; i < getKeys.length; i++) {
      final data = _sharedPreferences.getString(getKeys[i]);
      if (data != null) {
        dataList.add(BarcodeModel.fromJson(data));
      }
    }
    return dataList;
  }

  void clearSharedPref() async {
    _sharedPreferences.getKeys();
    await _sharedPreferences.clear();
  }
}
