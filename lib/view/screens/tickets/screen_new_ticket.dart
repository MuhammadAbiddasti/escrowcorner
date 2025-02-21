import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../../../widgets/custom_button/damaspay_button.dart';
import '../../controller/logo_controller.dart';
import '../../theme/damaspay_theme/Damaspay_theme.dart';
import '../user_profile/user_profile_controller.dart';
import 'ticket_controller.dart';

class ScreenNewTicket extends StatelessWidget {
  final LogoController logoController = Get.put(LogoController());
  final TicketController controller = Get.put(TicketController());
  final UserProfileController userProfileController =Get.find<UserProfileController>();

  @override
  void initState() {
    //super.initState();
    // Fetch escrows only once when the screen is initialized
    controller.fetchCategories();
  }
  void onInit() {
    controller.fetchCategories();
  }
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
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //CustomBtcContainer().paddingOnly(top: 20),
              Container(
                //height: MediaQuery.of(context).size.height * 0.68,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xffFFFFFF),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Open New Support Ticket",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xff18CE0F),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10),
                    Text(
                      "Title",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        contentPadding: EdgeInsets.only(top: 4, left: 5),
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                      ),
                    ),
                    Text(
                      "Category",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    Obx(
                          () => DropdownButtonFormField<Category>(
                        value: controller.selectedCategory.value.isEmpty
                            ? null
                            : controller.categories.firstWhereOrNull(
                                (category) => category.name == controller.selectedCategory.value),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5),
                          hintText: "Select Category",
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                        ),
                        icon: controller.isLoading.value
                            ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                          ),
                        )
                            : Icon(Icons.expand_more),
                        items: controller.categories.map((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: controller.isLoading.value
                            ? null
                            : (Category? selectedCategory) {
                          if (selectedCategory != null) {
                            controller.selectedCategory.value = selectedCategory.name;
                            controller.selectedCategoryId.value = selectedCategory.id;
                          }
                        },
                      ),
                    ),
                    Text(
                      "Priority",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    Obx(
                          () => DropdownButtonFormField<String>(
                        value: controller.selectedPriority.value.isEmpty
                            ? null
                            : controller.selectedPriority.value, // Set the selected value
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(top: 4, left: 5),
                          hintText: "Select Priority",
                          hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff666565)),
                          ),
                        ),
                        icon: Icon(Icons.expand_more), // Dropdown icon
                        items: controller.priorities.map((String priority) {
                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedPriority.value = newValue; // Update the selected value
                          }
                        },
                      ),
                    ),

                    Text(
                      "Message",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xff484848),
                        fontFamily: 'Nunito',
                      ),
                    ).paddingOnly(top: 10, bottom: 10),
                    TextField(
                      controller: controller.messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Write your message...",
                        contentPadding: EdgeInsets.only(top: 4, left: 5),
                        hintStyle: TextStyle(color: Color(0xffA9A9A9)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff666565)),
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () async{
                        // Adding a delay of 3 seconds before the API call
                        await Future.delayed(Duration(seconds: 2));
                        await controller.openNewTicket(context);
                      },
                      text: 'OPEN TICKET',
                      options: FFButtonOptions(
                        width: Get.width,
                        height: 45.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: DamaspayTheme.of(context).primary,
                        textStyle:
                        DamaspayTheme.of(context).titleSmall.override(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                        elevation: 2.0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ).paddingOnly(top: 30,bottom: 20),
                  ],
                ).paddingSymmetric(horizontal: 15),
              ).paddingOnly(top: 30, bottom: 30),
              CustomBottomContainer()
            ],
          ),
        ),
      ),
    );
  }
}
