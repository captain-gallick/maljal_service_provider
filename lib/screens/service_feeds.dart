import 'dart:convert';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/constants/app_urls.dart';
import 'package:maljal_service_provider/data_models/my_services.dart';
import 'package:maljal_service_provider/screens/contact_us.dart';
import 'package:maljal_service_provider/screens/service_details.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/network_checkup.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

import '../data_models/vendors.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';

List<MyServices> myServices = [];

class ServiceFeedsScreen extends StatefulWidget {
  const ServiceFeedsScreen({Key? key}) : super(key: key);

  @override
  _ServiceFeedsScreenState createState() => _ServiceFeedsScreenState();
}

class _ServiceFeedsScreenState extends State<ServiceFeedsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //late ScrollController _scrollController;
  bool showList = false;
  int currentIndex = 0;
  late BuildContext dialogContext;
  late BuildContext buildContext;
  int pageno = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _setTab();
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) => getRating());
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMapMethod('SystemNavigator.pop');
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
              child: (user == null)
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                    )
                  : getDrawer()),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.backgroundcolor,
            leading: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: Image.asset(
                  'assets/images/menu.png',
                  color: AppColors.appTextDarkBlue,
                )),
            title: const Text(
              'SERVICE FEED',
              style: TextStyle(color: AppColors.appTextDarkBlue),
            ),
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    NetworkCheckUp().checkConnection().then((value) {
                      if (value) {
                        showList = !showList;
                        setState(() {
                          getServiceFeed(pageno);
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Please connect to internet."),
                        ));
                      }
                    });
                  },
                  icon: const Icon(Icons.refresh,
                      color: AppColors.appTextDarkBlue))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          AppColors.lightTextColor,
                          AppColors.lightTextColor
                        ]),
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(2.0),
                    controller: _tabController,
                    // give the indicator a decoration (color and border radius)
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ),
                        color: AppColors.appAlmostWhite),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: const [
                      Tab(
                        text: 'NEW',
                      ),
                      Tab(
                        text: 'ON GOING',
                      ),
                      Tab(
                        text: 'COMPLETED',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    dragStartBehavior: DragStartBehavior.start,
                    children: [
                      ((showList) ? createListUI() : getSkeleton()),
                      ((showList) ? createListUI() : getSkeleton()),
                      ((showList) ? createListUI() : getSkeleton()),
                    ],
                  ),
                ),
                Visibility(
                  visible:
                      (pageno == 0 && myServices.length == 10) || (pageno != 0),
                  child: Column(
                    children: [
                      Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Visibility(
                            visible: (pageno > 0),
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  showList = !showList;
                                  pageno--;
                                  getServiceFeed(pageno);
                                });
                              },
                              child: const Text(
                                'Prev',
                              ),
                            ),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Visibility(
                              visible: (myServices.length > 9),
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showList = !showList;
                                      pageno++;
                                      getServiceFeed(pageno);
                                    });
                                  },
                                  child: const Text(
                                    'Next',
                                  ))),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 4,
      //controller: _scrollController,
      itemBuilder: (context, position) {
        return Column(
          children: [
            ListTile(
              leading: const SkeletonAvatar(
                  style: SkeletonAvatarStyle(width: 20, height: 20)),
              title: SkeletonLine(
                style: SkeletonLineStyle(
                    height: 16,
                    width: 100,
                    borderRadius: BorderRadius.circular(8)),
              ),
              subtitle: SkeletonLine(
                style: SkeletonLineStyle(
                    height: 16,
                    width: 70,
                    borderRadius: BorderRadius.circular(8)),
              ),
              trailing: const SkeletonAvatar(
                  style: SkeletonAvatarStyle(width: 20, height: 20)),
            ),
            Container(
              height: 5.0,
              color: Colors.grey.shade200,
            ),
          ],
        );
      },
    );
  }

  createListUI() {
    if (myServices.isNotEmpty) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: myServices.length,
        //controller: _scrollController,
        itemBuilder: (context, position) {
          return GestureDetector(
              onTap: () {
                NavigationHelper().openTempScreen(context,
                    ServiceDetailsScrceen(myServices: myServices[position]));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Color.fromARGB(255, 235, 235, 235), width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                color: AppColors.appLightBlue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: (position.isEven
                        ? Image.asset('assets/images/user_green.png')
                        : Image.asset('assets/images/user_blue.png')),
                    title: Text(
                      myServices[position].username,
                      style: const TextStyle(fontSize: 22.0),
                    ),
                    subtitle: RichText(
                        text: TextSpan(
                            text: myServices[position]
                                    .addedOn
                                    .replaceAll(' ', ' | ') +
                                " | " +
                                'STATUS: ',
                            style: const TextStyle(
                                color: AppColors.appTextDarkBlue),
                            children: <TextSpan>[
                          TextSpan(
                            text: getStatus(myServices[position].status),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ])),

                    /* Text(
                      myServices[position].addedOn.replaceAll(' ', ' | ') +
                          " | " +
                          'STATUS:' +
                          getStatus(myServices[position].status,
                              myServices[position].vendormsg)), */
                    trailing: ClipRRect(
                      child: SizedBox(
                          height: 70.0,
                          width: 70.0,
                          child: (myServices[position].image.endsWith('in/'))
                              ? Container()
                              : _getImage(myServices[position].image)),
                    ),
                  ),
                ),
              ));
        },
      );
    } else {
      return const Center(child: Text("Nothing to show."));
    }
  }

  _getImage(String image) {
    try {
      return Image.network(image);
    } catch (e) {}
  }

  _setTab() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        showList = !showList;
        currentIndex = _tabController.index;
        pageno = 0;
        getServiceFeed(pageno);
      });
    }
  }

  String getStatus(String s) {
    String status = '';
    if (s == '1') {
      status = 'NEW';
    } else if (s == '3') {
      status = 'COMPLETE';
    } else if (s == '5') {
      status = 'ON-HOLD';
    } else {
      status = 'ON GOING';
    }
    return status;
  }

  String getUrl(int index) {
    String url = '';
    switch (index) {
      case 0:
        url = AppUrl.newRequests;
        break;
      case 1:
        url = AppUrl.pendingRequests;
        break;
      case 2:
        url = AppUrl.completedRequests;
        break;
      default:
    }
    return url;
  }

  Vendor? user;

  getRating() async {
    String token = await SharedPreferencesHelper().getToken();
    final Response response = await get(
      Uri.parse(AppUrl.vendorProfile),
      headers: <String, String>{'token': token},
    );
    if (!(jsonDecode(response.body).toString().toLowerCase())
        .contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(jsonDecode(response.body)['message'].toString().toUpperCase()),
      ));
    } else {
      user = Vendor.fromJson(jsonDecode(response.body)['data']);

      SharedPreferencesHelper sharedPreferences = SharedPreferencesHelper();

      String address = user!.building +
          ", " +
          user!.area +
          ", " +
          user!.ward +
          ", " +
          user!.city +
          ", " +
          user!.pincode +
          ", ";
      await sharedPreferences.setVendor(user!, address);
      getServiceFeed(pageno);
    }
  }

  getServiceFeed(int pageNo) async {
    NetworkCheckUp().checkConnection().then((value) async {
      if (value) {
        //showLoader();
        try {
          myServices.clear();
          String page = pageno.toString();
          String token = await SharedPreferencesHelper().getToken();
          //print(token);
          final Response response = await get(
              Uri.parse(
                  getUrl(currentIndex) + '?pageno=' + page + '&pagesize=10'),
              headers: <String, String>{'token': token});

          if ((jsonDecode(response.body)['data'] != null)) {
            List<dynamic> list = jsonDecode(response.body)['data'];
            for (int i = 0; i < list.length; i++) {
              myServices.add(MyServices.fromJson(list[i]));
            }
            setState(() {
              showList = !showList;
              //Navigator.pop(dialogContext);
            });
          } else {
            myServices.clear;
            setState(() {
              showList = !showList;
              //Navigator.pop(dialogContext);
            });
          }
        } catch (e) {
          //print(e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please connect to internet."),
        ));
      }
    });
  }

  getDrawer() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset('assets/images/logo.png'),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListTile(
                title: const Text("PROFILE",
                    style: TextStyle(
                        fontSize: 20.0, color: AppColors.appTextDarkBlue)),
                onTap: () {
                  NavigationHelper()
                      .openTempScreen(context, const ProviderScreen());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListTile(
                title: const Text("YOUR RATINGS",
                    style: TextStyle(
                        fontSize: 20.0, color: AppColors.appTextDarkBlue)),
                subtitle: getRatingLayout(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListTile(
                title: const Text("CONTACT US",
                    style: TextStyle(
                        fontSize: 20.0, color: AppColors.appTextDarkBlue)),
                onTap: () {
                  NavigationHelper()
                      .openTempScreen(context, const ContactScreen());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListTile(
                title: const Text("LOGOUT",
                    style: TextStyle(
                        fontSize: 20.0, color: AppColors.appTextDarkBlue)),
                onTap: () {
                  SharedPreferencesHelper().logout().then((value) =>
                      NavigationHelper()
                          .navigateTo(context, const SplashScreen()));
                },
              ),
            ),
          ]),
        )
      ],
    );
  }

  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Please wait...'),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  getRatingLayout() {
    int rating = double.parse(user!.rating).toInt();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < rating; i++)
          const Icon(
            Icons.star_rate_rounded,
            color: Colors.amber,
            size: 16,
          ),
        const SizedBox(
          width: 10,
        ),
        Text(
          '(' +
              user!.rating.toString() +
              '/' +
              user!.ratingOutOf +
              ' ,' +
              user!.ratingCount +
              ' Reviews)',
          style: const TextStyle(color: AppColors.appTextDarkBlue),
        )
      ],
    );
  }

  /* _scrollListener() {
    setState(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // user is at top of the list
        } else {
          pageno = pageno + 1;
          getServiceFeed(pageno);
          // user is at the bottom of the list.
          // load next 10 items and add them to the list of items in the list.
        }
      }
    });
  } */
}
