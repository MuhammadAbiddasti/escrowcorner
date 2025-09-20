# Escrow Button Size and Text Update

## Overview
Updated all button sizes and text in escrow screens to be smaller and more consistent across the application.

## Changes Made

### 1. CustomButton Widget (`lib/widgets/custom_button/custom_button.dart`)
- **Default height**: Changed from 45px to 35px
- **Default font size**: Changed from 14px to 12px
- **Font weight**: Maintained at FontWeight.w500

### 2. Escrow List Screen (`lib/view/screens/escrow_system/send_escrow/screen_escrow_list.dart`)
- **Add Escrow button**: Height 30px, font size 11px
- **Action buttons** (View, Information, Release): Height 28px, font size 10px
- **Padding**: Reduced vertical padding from 15px to 10px

### 3. Received Escrow Screen (`lib/view/screens/escrow_system/received_escrow/get_received_escrow.dart`)
- **Action buttons** (View, Information, Reject): Height 28px, font size 10px

### 4. Requested Escrow Screen (`lib/view/screens/escrow_system/get_requested_escrow/get_requested_escrow.dart`)
- **Action buttons** (View, Information, Reject, Approve, Release): Height 28px, font size 10px

### 5. Cancelled Escrow Screen (`lib/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart`)
- **Action buttons** (View, Information): Height 28px, font size 10px

### 6. Request Escrow Screen (`lib/view/screens/escrow_system/request_escrow/request_escrow.dart`)
- **Add New button**: Height 30px, font size 11px
- **Action buttons** (View, Information, Cancel): Height 28px, font size 10px

### 7. Rejected Escrow Screen (`lib/view/screens/escrow_system/rejected_escrow/get_rejected_escrow.dart`)
- **Action buttons** (View, Information): Height 28px, font size 10px

### 8. Request Escrow Detail Screen (`lib/view/screens/escrow_system/request_escrow/request_escrow_detail.dart`)
- **Cancel Request button**: Font size 12px
- **Reject button**: Height 30px, font size 12px

## Button Size Standards

### Primary Action Buttons (Add/Create)
- **Height**: 30px
- **Font Size**: 11px
- **Font Weight**: FontWeight.w500

### Secondary Action Buttons (View, Information, etc.)
- **Height**: 28px
- **Font Size**: 10px
- **Font Weight**: FontWeight.w500

### Detail Screen Buttons
- **Height**: 30px
- **Font Size**: 12px
- **Font Weight**: FontWeight.w500

## Benefits
1. **Consistent UI**: All escrow screens now have uniform button sizing
2. **Better Space Utilization**: Smaller buttons allow more content to fit on screen
3. **Improved Readability**: Appropriate font sizes maintain readability while saving space
4. **Professional Appearance**: More compact and polished look across all escrow screens

## Files Modified
- `lib/widgets/custom_button/custom_button.dart`
- `lib/view/screens/escrow_system/send_escrow/screen_escrow_list.dart`
- `lib/view/screens/escrow_system/received_escrow/get_received_escrow.dart`
- `lib/view/screens/escrow_system/get_requested_escrow/get_requested_escrow.dart`
- `lib/view/screens/escrow_system/cancelled_escrow/get_cancelled_escrow.dart`
- `lib/view/screens/escrow_system/request_escrow/request_escrow.dart`
- `lib/view/screens/escrow_system/rejected_escrow/get_rejected_escrow.dart`
- `lib/view/screens/escrow_system/request_escrow/request_escrow_detail.dart`
