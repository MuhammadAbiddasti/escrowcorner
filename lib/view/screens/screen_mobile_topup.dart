import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar/custom_appbar.dart';
import '../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../controller/logo_controller.dart';

class ScreenMobileTopUp extends StatelessWidget {
  TextEditingController countrypic =TextEditingController();
  final LogoController logoController = Get.put(LogoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xffE6F0F7),
      appBar:  AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        //leading: PopupMenuButtonLeading(),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),

        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CustomBtcContainer().paddingOnly(top: 20),
              Container(
                //height: 469,
                height: MediaQuery.of(context).size.height * 0.64,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Money Transfer",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff18CE0F),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10),
                    Text(
                      "Choose Country",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    Container(
                      height: 42,
                      child: TextFormField(
                        controller: countrypic,
                        decoration: InputDecoration(
                          hintText: "-select-",
                          contentPadding: EdgeInsets.only(top: 4,left: 5),
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          suffixIcon: IconButton(onPressed: (){
                            showCountryPicker(
                                context: context,
                                showPhoneCode: true, // optional. Shows phone code before the country name.
                                onSelect: (Country country) {
                                  print('Select country: ${country.displayName}');
                                  countrypic.text ='${country.flagEmoji} ${country.displayNameNoCountryCode}';
                                }

                            );
                          }, icon: Icon(Icons.expand_more)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565),),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Operator",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    Container(
                      height: 42,
                      child: TextFormField(
                        decoration: InputDecoration(
                          suffixIcon: PopupMenuButton<String>(color: Colors.white,
                            icon: Icon(Icons.expand_more),
                            onSelected: (String result) {
                              //menuController.updateSelectedOption(result);
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: '1',
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Operator 1'),
                                    Divider(),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: '2',
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Operator 2'),
                                    Divider()
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: '3',
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Operator 3'),
                                    Divider()
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: '3',
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Add more countries as required...'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          contentPadding: EdgeInsets.only(top: 4,left: 5),
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565),),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Phone Number",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    Container(
                      height: 54,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        //controller: countrycode,
                        decoration: InputDecoration(
                          //contentPadding: EdgeInsets.only(left: 5),
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565),),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Amount in USD",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 10,bottom: 10),
                    Container(
                      height: MediaQuery.of(context).size.height*.12,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          contentPadding: EdgeInsets.only(top: 4,left: 5),
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff666565))),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565),),
                          ),
                        ),
                      ),
                    ),
                    CustomButton(
                        width: MediaQuery.of(context).size.width * 0.9,
                        text: "Send Money", onPressed: (){})
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 20,bottom: 20),
              CustomBottomContainer()
            ],
          ),
        ),
      ),

    );
  }
}
