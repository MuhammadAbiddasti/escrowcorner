import 'package:dacotech/view/screens/virtual_cards/virtualcard_controller.dart';
import 'package:dacotech/view/screens/virtual_cards/screen_add_virtualcard.dart';
import 'package:dacotech/widgets/custom_button/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_ballance_container/custom_btc_container.dart';
import '../../controller/logo_controller.dart';

class ScreenVirtualCard extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final VirtualCardController virtualCardController =
      Get.put(VirtualCardController());

  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    virtualCardController.fetchVirtualCards();
  }
  void onInit() {
    virtualCardController.fetchVirtualCards();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Color(0xffE6F0F7),
        appBar: AppBar(
          backgroundColor: Color(0xff0766AD),
          title: AppBarTitle(),
          //leading: PopupMenuButtonLeading(),
          actions: [
            PopupMenuButtonAction(),
            AppBarProfileButton(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: ()async {
            await virtualCardController.fetchVirtualCards();
          },
          child: SingleChildScrollView(
            child: Center(
                child: Column(children: [
                  //CustomBtcContainer().paddingOnly(top: 20),
              Container(
                //height: MediaQuery.of(context).size.height * .15,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  children: [
                    Text(
                      "Add a new Virtual Card",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xff484848),
                          fontFamily: 'Nunito'),
                    ).paddingOnly(top: 15),
                    CustomButton(
                        text: "ADD",
                        onPressed: () {
                          Get.to(ScreenAddVirtualCard());
                        }).paddingSymmetric(horizontal: 20, vertical: 10)
                  ],
                ),
              ).paddingOnly(top: 20),
              Container(
                  height: MediaQuery.of(context).size.height * .55,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Virtual Cards",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xff18CE0F),
                              fontFamily: 'Nunito'),
                        ).paddingOnly(top: 15, bottom: 12, left: 10),
                        Divider(color: Color(0xffDDDDDD)),
                        Expanded(child: Obx(() {
                          if (virtualCardController.isLoading.value) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (virtualCardController.virtualCards.isEmpty) {
                            return Center(child: Text("No virtual cards found"));
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Id')),
                                  DataColumn(label: Text('Card Number')),
                                  DataColumn(label: Text('Card Type')),
                                  DataColumn(label: Text('Action')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows:
                                    virtualCardController.virtualCards.map((card) {
                                  // Null checks and providing default values
                                  String id = card['id']?.toString() ?? '';
                                  String cardNumber = card['card_number'] ?? '';
                                  String cardType = card['card_type'] ?? '';
                                  String expMonth = card['exp_month'] ?? '';
                                  String expYear = card['exp_year'] ?? '';
                                  return DataRow(cells: [
                                    DataCell(Text(id)),
                                    DataCell(Text(cardNumber)),
                                    DataCell(Text(cardType)),
                                    DataCell(Text('$expMonth/$expYear')),
                                    DataCell(IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Implement delete action here
                                      },
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          );
                        }))
                      ])).paddingOnly(top: 20,bottom: 30),
                  CustomBottomContainer()
            ])),
          ),
        ));
  }
}
