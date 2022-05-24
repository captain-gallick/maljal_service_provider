class AppUrl {
  static String appUrl = 'https://maljal.org/';
  static String baseUrl = appUrl + 'vendorapi/';

  static String sendOtp = baseUrl + 'authentication/login';
  static String verifyOtp = baseUrl + 'authentication/verify';

  static String newRequests = baseUrl + 'booking/new';
  static String pendingRequests = baseUrl + 'booking/processing';
  static String completedRequests = baseUrl + 'booking/finished';

  static String accept = baseUrl + 'booking/process';
  static String finish = baseUrl + 'booking/finish';

  static String updateLocation =
      "https://maljal.org/vendorapi/booking/updateloc";
  static String decline = "https://maljal.org/vendorapi/booking/close";
  static String requestCode =
      "https://maljal.org/vendorapi/booking/requestcode";
}
