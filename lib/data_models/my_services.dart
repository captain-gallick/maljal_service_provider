class MyServices {
  String username;
  String servicename;
  String descr;
  String uemail;
  String uphone;
  String addedOn;
  String status;
  String image;
  String id;
  String building;
  String areaname;
  String pincode;
  String city;
  String lat;
  String lng;
  String vendormsg;
  String video;
  String landmark;
  String finishMedia;

  MyServices({
    required this.username,
    required this.servicename,
    required this.descr,
    required this.uemail,
    required this.uphone,
    required this.addedOn,
    required this.status,
    required this.image,
    required this.id,
    required this.building,
    required this.areaname,
    required this.pincode,
    required this.city,
    required this.lat,
    required this.lng,
    required this.vendormsg,
    required this.video,
    required this.landmark,
    required this.finishMedia,
  });

  factory MyServices.fromJson(Map<String, dynamic> responseData) {
    return MyServices(
      id: responseData['id'],
      username: responseData['name'],
      servicename: responseData['title'],
      descr: responseData['sdescr'],
      image: responseData['media'],
      video: responseData['media1'],
      uemail: responseData['email'],
      uphone: responseData['phone'],
      addedOn: responseData['added_on'],
      status: responseData['status'],
      building: responseData['building'],
      areaname: responseData['areaname'],
      pincode: responseData['pincode'],
      city: responseData['cityname'],
      lat: responseData['lat'],
      lng: responseData['lng'],
      vendormsg: responseData['vendor_msg'],
      landmark: responseData['landmark'],
      finishMedia: responseData['finish_media'],
    );
  }
}
