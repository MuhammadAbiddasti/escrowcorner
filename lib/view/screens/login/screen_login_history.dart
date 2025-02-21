import 'package:dacotech/view/screens/login/login_history_controller.dart';
import 'package:dacotech/widgets/custom_bottom_container/custom_bottom_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenLoginHistory extends StatelessWidget {
  final LoginHistoryController controller = Get.put(LoginHistoryController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    controller.fetchLoginDetails(context);
    return Scaffold(
      backgroundColor: const Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: const Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: Stack(
        children:[
          RefreshIndicator(
          onRefresh: () async {
            await controller.fetchLoginDetails(context);
          },
          child: ListView(
            children:[
              Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height*0.7,
                  width: MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xffFFFFFF),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Login History",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xff18CE0F),
                            fontFamily: 'Nunito'),).paddingOnly(top: 10),
                      Obx(() {
                        if (controller.isLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        } else if (controller.loginHistory.isEmpty) {
                          return Center(child: Text('No login history found.'));
                        } else {
                          return Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal, // Enable horizontal scrolling for DataTable
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Sr No',style: TextStyle(fontWeight: FontWeight.bold),)),
                                    DataColumn(label: Text('User Name',style: TextStyle(fontWeight: FontWeight.bold),)),
                                    DataColumn(label: Text('Login Date',style: TextStyle(fontWeight: FontWeight.bold),)),
                                    DataColumn(label: Text('IP Address',style: TextStyle(fontWeight: FontWeight.bold),)),
                                    DataColumn(label: Text('Login Device',style: TextStyle(fontWeight: FontWeight.bold),)),
                                    DataColumn(label: Text('Login Browser',style: TextStyle(fontWeight: FontWeight.bold),)),
                                  ],
                                  rows: List<DataRow>.generate(
                                    controller.loginHistory.length,
                                        (index) {
                                      var history = controller.loginHistory[index];
                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(history['user_name'] ?? 'N/A')),
                                          DataCell(Text(history['login_date'] ?? 'N/A')),
                                          DataCell(Text(history['ip_address'] ?? 'N/A')),
                                          DataCell(Text(history['login_device'] ?? '')),
                                          DataCell(Text(history['login_browser'] ?? '')),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ).paddingOnly(top: 20,bottom: 20),

              ],
            ),]
          ),
        ),
          Align(alignment: Alignment.bottomCenter,
              child: CustomBottomContainer())
        ]
      ),
    );
  }
}
