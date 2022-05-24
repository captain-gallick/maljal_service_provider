import 'package:flutter/material.dart';
import 'package:maljal_service_provider/constants/app_colors.dart';
import 'package:maljal_service_provider/my_widgets/text_field.dart';
import 'package:maljal_service_provider/utils/my_navigator.dart';
import 'package:maljal_service_provider/utils/shared_preferences.dart';

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({Key? key}) : super(key: key);

  @override
  _ProviderScreenState createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final aadharController = TextEditingController();
  final companyController = TextEditingController();
  final gstController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              NavigationHelper().closeTempScreen(context);
              return false;
            },
            child: Scaffold(
                appBar: AppBar(
                  title: const Align(
                      alignment: Alignment(-0.25, 0.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(color: AppColors.appTextDarkBlue),
                      )),
                  backgroundColor: AppColors.backgroundcolor,
                  elevation: 0,
                  leading: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.appTextDarkBlue,
                      ),
                      onPressed: () {
                        NavigationHelper().closeTempScreen(context);
                      }),
                ),
                body: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(child: registrationForm())))));
  }

  Container registrationForm() {
    SharedPreferencesHelper().getVendor().then((value) {
      nameController.text = value['name'] ?? '';
      emailController.text = value['email'] ?? '';
      addressController.text = value['address'] ?? '';
      phoneController.text = value['phone'] ?? '';
      companyController.text = value['company'] ?? '';
      gstController.text = value['gst'] ?? '';
      aadharController.text = value['aadhar'] ?? '';
    });

    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              heading('Full Name'),
              MyTextField(
                hint: "Enter your Name",
                key: null,
                active: false,
                myController: nameController,
              ),
              heading('Email'),
              MyTextField(
                hint: "Email",
                key: null,
                active: false,
                myController: emailController,
              ),
              heading('Phone'),
              MyTextField(
                hint: "Phone Number",
                key: null,
                active: false,
                myController: phoneController,
              ),
              heading('Address'),
              MyTextField(
                hint: "Address",
                key: null,
                active: false,
                myController: addressController,
              ),
              heading('Aadhar Number'),
              MyTextField(
                hint: "Aadhar Number",
                key: null,
                active: false,
                myController: aadharController,
              ),
              heading('Company'),
              MyTextField(
                hint: "Company",
                key: null,
                active: false,
                myController: companyController,
              ),
              heading('GST Number'),
              MyTextField(
                type: TextInputType.number,
                hint: "GST Number",
                key: null,
                active: false,
                myController: gstController,
              ),
              /* heading('Building Name'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Building Name",
                key: null,
                myController: buildingController,
              ),
              heading('Area'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Area",
                key: null,
                myController: areaController,
              ),
              heading('Ward'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Ward",
                key: null,
                myController: wardController,
              ),
              heading('Pincode'),
              MyTextField(
                length: 6,
                type: TextInputType.number,
                hint: "Enter your Pincode",
                key: null,
                myController: pincodeController,
              ),
              heading('City'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your City",
                key: null,
                myController: cityController,
              ), */
              const SizedBox(
                height: 40.0,
              ),
            ]));
  }

  Padding heading(title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.appTextDarkBlue,
        ),
      ),
    );
  }
}
