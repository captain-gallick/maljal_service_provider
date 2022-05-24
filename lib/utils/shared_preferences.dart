import 'package:maljal_service_provider/data_models/vendors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  final String _token = 'token';
  final String _isLoggedIn = 'isLoggedIn';
  final String _welcomeShown = 'welcomeShown';
  final String _locationDialogShown = 'locationDialogShown';

  Future<bool> setToken(String token) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    if (await sharedPreferences.setString(_token, token)) {
      return await sharedPreferences.setBool(_isLoggedIn, true);
    } else {
      return false;
    }
  }

  Future<bool> setWelcomeShown() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.setBool(_welcomeShown, true);
  }

  Future<bool> setLocationDialog(int val) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.setInt(_locationDialogShown, val);
  }

  Future<bool> setVendor(Vendor vendor, String address) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    await sharedPreferences.setString("name", vendor.name);
    await sharedPreferences.setString("email", vendor.email);
    await sharedPreferences.setString("phone", vendor.phone);
    await sharedPreferences.setString("aadhar", vendor.aadhar);
    await sharedPreferences.setString("company", vendor.gst);
    return await sharedPreferences.setString("address", address);
  }

  Future<Map<String, String>> getVendor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String name = prefs.getString('name') as String;
    String email = prefs.getString('email') as String;
    String phone = prefs.getString('phone') as String;
    String aadhar = prefs.getString('aadhar') as String;
    String company = prefs.getString('company') as String;
    String address = prefs.getString('address') as String;

    Map<String, String> map = {};
    map.addAll({
      'name': name,
      'email': email,
      'phone': phone,
      'aadhar': aadhar,
      'company': company,
      'address': address
    });
    return map;
  }

  Future<String> getToken() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    if (sharedPreferences.getBool(_isLoggedIn) ?? false) {
      return sharedPreferences.getString(_token) as String;
    } else {
      return '';
    }
  }

  Future<bool> isWelcomeShown() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_welcomeShown) ?? false;
  }

  Future<int> islocationDialogShown() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getInt(_locationDialogShown) ?? 0;
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_isLoggedIn) ?? false;
  }

  Future<bool> logout() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return await sharedPreferences.clear();
  }
}
