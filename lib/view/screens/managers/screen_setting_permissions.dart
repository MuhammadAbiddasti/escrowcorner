import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../user_profile/user_profile_controller.dart';

class ScreenSettingsPermission extends StatefulWidget {
  @override
  _ScreenSettingsPermissionState createState() =>
      _ScreenSettingsPermissionState();
}

class _ScreenSettingsPermissionState extends State<ScreenSettingsPermission> {
  // Updated checkbox lists to accommodate 18 fields
  List<bool> viewPermissions = List.generate(18, (index) => false);
  List<bool> addPermissions = List.generate(18, (index) => false);
  List<bool> editPermissions = List.generate(18, (index) => false);
  List<bool> deletePermissions = List.generate(18, (index) => false);

  final List<int> singleCheckboxRows = [0, 2, 4, 7, 13, 14, 15,]; // Row indices with only "View"
  final List<int> twoCheckboxRows = [11, 12];
  final List<int> threeCheckboxRows = [17];
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff0766AD),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value,),
        actions: [
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assign Permission To Manager",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('View')),
                        DataColumn(label: Text('Add')),
                        DataColumn(label: Text('Edit')),
                        DataColumn(label: Text('Delete')),
                      ],
                      rows: [
                        buildDataRow('Dashboard', 0),
                        buildDataRow('Transfer Money', 1),
                        buildDataRow('Payment Link', 2),
                        buildDataRow('Support Ticket', 3),
                        buildDataRow('Api Keys', 4),
                        buildDataRow('My Deposits', 5),
                        buildDataRow('My Withdrawals', 6),
                        buildDataRow('All Transactions', 7),
                        buildDataRow('Settings', 8),
                        buildDataRow('Managers', 9),
                        buildDataRow('Request Money', 10),
                        buildDataRow('Send Escrow', 11),
                        buildDataRow('Request Escrow', 12),
                        buildDataRow('Received Escrow', 13),
                        buildDataRow('Rejected Escrow', 14),
                        buildDataRow('Requested  Escrow', 15),
                        buildDataRow('Cancelled  Escrow', 16),
                        buildDataRow('My Application', 17),
                      ],
                    ),
                    CustomButton(
                      width: Get.width * .7,
                      text: "Assign Permission",
                      onPressed: () {},
                    ).paddingSymmetric(horizontal: 20, vertical: 20),
                  ],
                ),
              ),
            ).paddingOnly(top: 20, bottom: 30),
          ],
        ).paddingSymmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  DataRow buildDataRow(String label, int index) {
    bool singleCheckbox = singleCheckboxRows.contains(index);
    bool twoCheckbox = twoCheckboxRows.contains(index);
    bool threeCheckbox = threeCheckboxRows.contains(index);

    return DataRow(cells: [
      DataCell(Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
      )),
      // "View" checkbox (always shown)
      DataCell(Checkbox(
        value: viewPermissions[index],
        onChanged: (bool? value) {
          setState(() {
            viewPermissions[index] = value!;
          });
        },
      )),
      // "Add" checkbox
      DataCell(
        singleCheckbox
            ? SizedBox.shrink() // Hide for singleCheckbox rows
            : Checkbox(
          value: addPermissions[index],
          onChanged: (bool? value) {
            setState(() {
              addPermissions[index] = value!;
            });
          },
        ),
      ),
      // "Edit" checkbox
      DataCell(
        singleCheckbox || twoCheckbox
            ? SizedBox.shrink() // Hide for singleCheckbox or twoCheckbox rows
            : Checkbox(
          value: editPermissions[index],
          onChanged: (bool? value) {
            setState(() {
              editPermissions[index] = value!;
            });
          },
        ),
      ),
      // "Delete" checkbox
      DataCell(
        singleCheckbox || twoCheckbox || threeCheckbox
            ? SizedBox.shrink() // Hide for singleCheckbox, twoCheckbox, or threeCheckbox rows
            : Checkbox(
          value: deletePermissions[index],
          onChanged: (bool? value) {
            setState(() {
              deletePermissions[index] = value!;
            });
          },
        ),
      ),
    ]);
  }

}
