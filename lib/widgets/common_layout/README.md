# Common Layout Components

This directory contains reusable layout components that provide consistent header and footer across all pages after login.

## Components

### 1. CommonLayout
A wrapper widget that provides:
- Consistent AppBar with dark theme (`Color(0xff191f28)`)
- Custom popup menu and profile button
- Bottom container with footer
- Scrollable content area
- Optional refresh functionality

### 2. CommonLayoutFullScreen
A wrapper widget for pages that need full screen without bottom container:
- Same AppBar as CommonLayout
- Full screen content without bottom footer
- Optional refresh functionality

## Usage Examples

### Basic Usage (with bottom container)
```dart
import '../../../widgets/common_layout/common_layout.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "My Page Title",
      child: Column(
        children: [
          // Your page content here
          Container(
            child: Text("Page Content"),
          ),
        ],
      ),
    );
  }
}
```

### Usage without bottom container
```dart
import '../../../widgets/common_layout/common_layout.dart';

class MyFullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "My Page Title",
      showBottomContainer: false, // Hide bottom container
      child: Column(
        children: [
          // Your page content here
          Container(
            child: Text("Page Content"),
          ),
        ],
      ),
    );
  }
}
```

### Usage with refresh functionality
```dart
import '../../../widgets/common_layout/common_layout.dart';

class MyRefreshablePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: "My Page Title",
      enableRefresh: true,
      onRefresh: () async {
        // Your refresh logic here
        await fetchData();
      },
      child: Column(
        children: [
          // Your page content here
          Container(
            child: Text("Page Content"),
          ),
        ],
      ),
    );
  }
}
```

### Full screen layout without bottom container
```dart
import '../../../widgets/common_layout/common_layout.dart';

class MyFullScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonLayoutFullScreen(
      title: "My Page Title",
      child: Column(
        children: [
          // Your page content here
          Container(
            child: Text("Page Content"),
          ),
        ],
      ),
    );
  }
}
```

## Migration Guide

### Before (Old way)
```dart
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
```

### After (New way)
```dart
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

## Benefits

1. **Consistency**: All pages have the same header and footer design
2. **Maintainability**: Changes to header/footer only need to be made in one place
3. **Reduced Code**: Eliminates repetitive Scaffold/AppBar code
4. **Flexibility**: Easy to enable/disable features like refresh and bottom container
5. **Type Safety**: Proper parameter validation and documentation

## Parameters

### CommonLayout Parameters
- `child` (required): The main content widget
- `title` (optional): Page title to display in AppBar
- `showBottomContainer` (optional): Whether to show bottom footer (default: true)
- `backgroundColor` (optional): Background color (default: Color(0xffE6F0F7))
- `enableRefresh` (optional): Enable pull-to-refresh (default: false)
- `onRefresh` (optional): Refresh callback function

### CommonLayoutFullScreen Parameters
- `child` (required): The main content widget
- `title` (optional): Page title to display in AppBar
- `backgroundColor` (optional): Background color (default: Color(0xffE6F0F7))
- `enableRefresh` (optional): Enable pull-to-refresh (default: false)
- `onRefresh` (optional): Refresh callback function 