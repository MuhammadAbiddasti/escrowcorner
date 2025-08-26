# Common Layout Migration Guide

This document provides a comprehensive guide for migrating all pages after login to use the new common layout components.

## ✅ Completed Pages

The following pages have been successfully migrated to use `CommonLayout`:

1. **Deposit Page** (`lib/view/screens/deposit/screen_deposit.dart`)
   - ✅ Updated to use `CommonLayout`
   - ✅ Removed custom AppBar and bottom container
   - ✅ Added proper title "Deposit"

2. **Withdraw Page** (`lib/view/screens/withdraw/screen_withdrawal.dart`)
   - ✅ Updated to use `CommonLayout`
   - ✅ Removed custom AppBar and bottom container
   - ✅ Added proper title "Withdraw"

3. **User Profile Page** (`lib/view/screens/user_profile/screen_person_info.dart`)
   - ✅ Updated to use `CommonLayout`
   - ✅ Added refresh functionality
   - ✅ Added proper title "Personal Information"

## 🔄 Pages to be Migrated

The following pages need to be updated to use the common layout:

### High Priority Pages
1. **Dashboard Page** (`lib/view/screens/dashboard/screen_dashboard.dart`)
   - Currently uses custom AppBar and bottom container
   - Has refresh functionality that should be preserved
   - Complex layout with multiple sections

2. **Settings Page** (`lib/view/screens/settings/screen_settings.dart`)
   - Uses custom AppBar
   - Needs bottom container

3. **KYC Screens** (Multiple files)
   - `lib/view/Kyc_screens/screen_kyc1.dart`
   - `lib/view/Kyc_screens/screen_kyc2.dart`
   - `lib/view/Kyc_screens/screen_kyc3.dart`
   - `lib/view/Kyc_screens/screen_kyc4.dart`

4. **Ticket Pages**
   - `lib/view/screens/tickets/screen_new_ticket.dart`
   - `lib/view/screens/tickets/screen_support_tickets.dart`
   - `lib/view/screens/tickets/screen_ticket_details.dart`

5. **Transaction Pages**
   - `lib/view/screens/Transactions/screen_all_transactions.dart`
   - `lib/view/screens/Transactions/screen_api_deposits.dart`
   - `lib/view/screens/Transactions/screen_api_withdrawals.dart`
   - `lib/view/screens/Transactions/screen_api_transactions.dart`

6. **Send Money Pages**
   - `lib/view/screens/send_money/screen_sendmoney.dart`
   - `lib/view/screens/send_money/screen_get_all_sendmoney.dart`

7. **Request Money Pages**
   - `lib/view/screens/request_money/screen_new_requestmoney.dart`
   - `lib/view/screens/request_money/screen_get_request_money.dart`

8. **Payment Links Pages**
   - `lib/view/screens/payment_links/screen_paymentlinks.dart`
   - `lib/view/screens/payment_links/screen_create_payment_link.dart`

9. **Escrow System Pages**
   - `lib/view/screens/escrow_system/screen_escrow_details.dart`
   - `lib/view/screens/escrow_system/screen_received_escrow.dart`
   - `lib/view/screens/escrow_system/send_escrow/screen_create_escrow.dart`
   - `lib/view/screens/escrow_system/send_escrow/screen_escrow_list.dart`
   - `lib/view/screens/escrow_system/request_escrow/request_escrow.dart`
   - `lib/view/screens/escrow_system/get_requested_escrow/get_requested_escrow.dart`
   - `lib/view/screens/escrow_system/received_escrow/get_received_escrow.dart`
   - `lib/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart`
   - `lib/view/screens/escrow_system/rejected_escrow/get_rejected_escrow.dart`

10. **Application Pages**
    - `lib/view/screens/applications/screen_merchant.dart`
    - `lib/view/screens/applications/screen_add_merchant.dart`
    - `lib/view/screens/applications/screen_edit_application.dart`
    - `lib/view/screens/applications/screen_transfer_in.dart`
    - `lib/view/screens/applications/screen_transfer_out.dart`

11. **Manager Pages**
    - `lib/view/screens/managers/screen_managers.dart`
    - `lib/view/screens/managers/screen_add_new_manager.dart`

12. **Other Pages**
    - `lib/view/screens/login/screen_login_history.dart`
    - `lib/view/screens/withdraw/screen_my_withdraw.dart`
    - `lib/view/screens/deposit/screen_my_deposit.dart`
    - `lib/view/screens/withdraw/screen_withdraw_otp.dart`
    - `lib/view/screens/change_password/screen_change_password.dart`
    - `lib/view/screens/change_password/password_verification_screen.dart`
    - `lib/view/screens/2fa_security/screen_2fa_security.dart`
    - `lib/view/screens/settings/screen_fees_charges.dart`
    - `lib/view/screens/settings/screen_general_settings.dart`
    - `lib/view/screens/settings/screen_settings_portion.dart`
    - `lib/view/screens/virtual_cards/screen_virtualcard.dart`
    - `lib/view/screens/virtual_cards/screen_add_virtualcard.dart`
    - `lib/view/screens/swapping/swapping_screen.dart`
    - `lib/view/screens/mobile_topup/screen_mobile_topup.dart`

## Migration Steps

### Step 1: Update Imports
Replace the old imports with the new common layout import:

```dart
// Remove these imports
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';

// Add this import
import '../../../widgets/common_layout/common_layout.dart';
```

### Step 2: Replace Scaffold with CommonLayout
Replace the entire Scaffold structure:

```dart
// Before
@override
Widget build(BuildContext context) {
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
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // Your content here
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CustomBottomContainer(),
        ),
      ],
    ),
  );
}

// After
@override
Widget build(BuildContext context) {
  return CommonLayout(
    title: "Your Page Title",
    child: Column(
      children: [
        // Your content here
      ],
    ),
  );
}
```

### Step 3: Handle Special Cases

#### For pages with refresh functionality:
```dart
return CommonLayout(
  title: "Your Page Title",
  enableRefresh: true,
  onRefresh: () async {
    // Your refresh logic here
    await fetchData();
  },
  child: Column(
    children: [
      // Your content here
    ],
  ),
);
```

#### For pages without bottom container:
```dart
return CommonLayout(
  title: "Your Page Title",
  showBottomContainer: false,
  child: Column(
    children: [
      // Your content here
    ],
  ),
);
```

#### For full screen pages:
```dart
return CommonLayoutFullScreen(
  title: "Your Page Title",
  child: Column(
    children: [
      // Your content here
    ],
  ),
);
```

## Benefits of Migration

1. **Consistency**: All pages will have the same header and footer design
2. **Maintainability**: Changes to header/footer only need to be made in one place
3. **Reduced Code**: Eliminates repetitive Scaffold/AppBar code
4. **Better UX**: Consistent navigation experience across the app
5. **Easier Testing**: Common layout can be tested once for all pages

## Testing Checklist

After migrating each page, verify:

- [ ] AppBar displays correctly with proper title
- [ ] Menu button (hamburger icon) works
- [ ] Profile button works
- [ ] Bottom container displays (if enabled)
- [ ] Page content scrolls properly
- [ ] Refresh functionality works (if enabled)
- [ ] Navigation between pages works correctly
- [ ] No console errors or warnings

## Notes

- The common layout automatically handles the dark theme AppBar (`Color(0xff191f28)`)
- The bottom container uses the post-login version (`CustomBottomContainerPostLogin`)
- All pages will have consistent background color (`Color(0xffE6F0F7)`)
- The layout automatically handles responsive design and scrolling 