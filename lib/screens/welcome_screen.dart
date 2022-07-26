import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/screens/login_screen.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

final List<String> headings = ['WELCOME'];
final List<String> description = ['TO UPAAY'];

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;
  bool skipShown = false;
  final CarouselController controller = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          Builder(
            builder: (context) {
              final double height = MediaQuery.of(context).size.height;
              return CarouselSlider(
                carouselController: controller,
                options: CarouselOptions(
                    height: height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                        if (index == headings.length - 1) {
                          skipShown = true;
                        } else {
                          skipShown = false;
                        }
                      });
                    }),
                items: headings
                    .map((item) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: !skipShown
                                      ? Text(item,
                                          style: const TextStyle(
                                              color: AppColors.appTextDarkBlue,
                                              fontSize: 70.0))
                                      : Text(item,
                                          style: const TextStyle(
                                              color: AppColors.appTextDarkBlue,
                                              fontSize: 40.0))),
                              Text(description[_current],
                                  style: const TextStyle(
                                      color: AppColors.appTextDarkBlue,
                                      fontSize: 30.0)),
                            ]))
                    .toList(),
              );
            },
          ),
          /* Positioned.fill(
                  bottom: 27,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: headings.asMap().entries.map((entry) {
                            return Container(
                              width: 10.0,
                              height: 10.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.green
                                          : Colors.white)
                                      .withOpacity(
                                          _current == entry.key ? 1.0 : 0.4)),
                            );
                          }).toList()))), */
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_right_alt),
              onPressed: skip,
              color: Colors.blueAccent,
            ), /* !skipShown
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.arrow_right_alt),
                        onPressed: skip,
                        color: Colors.blueAccent,
                      ), */
          ),
        ],
      )),
    ));
  }

  void skip() async {
    if (await SharedPreferencesHelper().setWelcomeShown()) {
      NavigationHelper().navigateTo(context, const LoginScreen());
    }
  }
}
