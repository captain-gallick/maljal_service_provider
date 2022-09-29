class AppUrl {
  static String appUrl = 'https://upaay.org.in/';
  static String baseUrl = appUrl + 'vendorapi/';

  static String sendOtp = baseUrl + 'authentication/login';
  static String verifyOtp = baseUrl + 'authentication/verify';
  static String vendorProfile =
      'https://upaay.org.in/vendorapi/booking/profile';

  static String newRequests = baseUrl + 'booking/new';
  static String pendingRequests = baseUrl + 'booking/processing';
  static String completedRequests = baseUrl + 'booking/finished';

  static String accept = baseUrl + 'booking/process';
  static String proof = baseUrl + 'booking/proof';
  static String finish = baseUrl + 'booking/finish';

  static String updateLocation =
      "https://upaay.org.in/vendorapi/booking/updateloc";
  static String decline = "https://upaay.org.in/vendorapi/booking/close";
  static String requestCode =
      "https://upaay.org.in/vendorapi/booking/requestcode";
}
