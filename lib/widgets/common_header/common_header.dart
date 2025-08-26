import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../custom_appbar/custom_appbar.dart';
import '../language_selector/language_selector_widget.dart';

class CommonHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String managerId;

  const CommonHeader({
    Key? key,
    required this.title,
    required this.managerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xff191f28),
      title: AppBarTitle(),
      leading: CustomPopupMenu(
        managerId: managerId,
      ),
      actions: [
        QuickLanguageSwitcher(),
        AppBarProfileButton(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
