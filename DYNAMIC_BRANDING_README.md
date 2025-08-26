# Dynamic Branding System for EscrowCorner

This document explains how to use the dynamic branding system that allows the app to fetch and display app icons and logos dynamically from the backend API.

## Overview

The dynamic branding system automatically fetches branding assets (app icons and logos) from the backend API and caches them locally. This allows administrators to update the app's visual branding without requiring a new app release.

## Features

- **Dynamic App Icon**: Fetches app icon from API and caches it locally
- **Dynamic Logo**: Fetches company logo from API and caches it locally
- **Automatic Caching**: Images are cached for 24 hours to reduce API calls
- **Fallback Support**: Uses local assets if API fails or images are unavailable
- **Real-time Updates**: Can be manually refreshed to get latest branding
- **Cross-platform**: Works on both Android and iOS

## API Endpoint

### Get Branding Settings
```
GET /api/get_setting
```

**Base URL**: `https://escrowcorner.com`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer {token} (optional)
```

**Response Format**:
```json
{
  "success": true,
  "data": {
    "app_icon": "https://escrowcorner.com/assets/images/1754390133_app_icon.jpeg",
    "site_logo": "https://escrowcorner.com/assets/logo/1754657168_logo.png"
  }
}
```

## Implementation

### 1. Controller

The `DynamicBrandingController` manages the dynamic branding system:

```dart
class DynamicBrandingController extends GetxController {
  var appLogo = Rx<File?>(null);
  var appIcon = Rx<File?>(null);
  var isLoading = false.obs;
  
  // Fetch branding from API
  Future<void> fetchBrandingFromAPI() async { ... }
  
  // Get logo widget
  Widget getLogoWidget({double? width, double? height, BoxFit fit}) { ... }
  
  // Get icon widget
  Widget getIconWidget({double? width, double? height, BoxFit fit}) { ... }
}
```

### 2. Widgets

Use these widgets to display dynamic branding:

```dart
// Dynamic Logo
DynamicLogoWidget(
  height: 150,
  width: 300,
  fit: BoxFit.contain,
  placeholder: YourPlaceholderWidget(),
)

// Dynamic Icon
DynamicIconWidget(
  height: 100,
  width: 100,
  fit: BoxFit.contain,
  placeholder: YourPlaceholderWidget(),
)
```

### 3. Service

The `DynamicBrandingService` handles image downloading and caching:

```dart
class DynamicBrandingService {
  // Download and cache image
  Future<File?> downloadAndCacheImage(String imageUrl, String fileName) async { ... }
  
  // Get cached image
  Future<File?> getCachedImage(String fileName) async { ... }
  
  // Clear cache
  Future<void> clearCache() async { ... }
}
```

## Usage Examples

### Basic Usage

```dart
// In your widget
final brandingController = Get.find<DynamicBrandingController>();

// Display dynamic logo
brandingController.getLogoWidget(
  width: 200,
  height: 100,
  fit: BoxFit.contain,
)

// Display dynamic icon
brandingController.getIconWidget(
  width: 64,
  height: 64,
  fit: BoxFit.contain,
)
```

### Manual Refresh

```dart
// Force refresh branding
await brandingController.forceRefresh();

// Clear cache
await brandingController.clearCache();
```

### Check Status

```dart
// Check if branding is up to date
bool isUpToDate = brandingController.isBrandingUpToDate();

// Get current URLs
String logoUrl = brandingController.getCurrentLogoUrl();
String iconUrl = brandingController.getCurrentIconUrl();

// Get cache statistics
Map<String, dynamic> stats = await brandingController.getCacheStats();
```

## Configuration

### Cache Duration

The default cache duration is 24 hours. You can modify this in the controller:

```dart
static const Duration cacheDuration = Duration(hours: 24);
```

### Fallback Images

Fallback images are defined in the controller:

```dart
// Fallback logo
Widget _getFallbackLogo(double? width, double? height, BoxFit fit) {
  return Image.asset('assets/images/logo.png', ...);
}

// Fallback icon
Widget _getFallbackIcon(double? width, double? height, BoxFit fit) {
  return Image.asset('assets/icon/icon.png', ...);
}
```

## Demo Screen

A demo screen is available at `lib/view/screens/demo/dynamic_branding_demo_screen.dart` that showcases all the dynamic branding features.

To access it, navigate to:
```dart
Get.to(() => DynamicBrandingDemoScreen());
```

## Image Requirements

### App Icon
- **Format**: PNG or JPEG
- **Size**: 512x512 pixels (square)
- **Max File Size**: 1MB
- **Background**: Transparent or solid color

### Logo
- **Format**: PNG, JPEG, or SVG
- **Size**: 512x256 pixels (2:1 aspect ratio recommended)
- **Max File Size**: 2MB
- **Background**: Transparent or white background preferred

## Error Handling

The system includes comprehensive error handling:

1. **Network Errors**: Falls back to cached images or local assets
2. **Invalid Images**: Shows fallback images with error indicators
3. **API Failures**: Continues using cached branding
4. **File System Errors**: Gracefully handles storage issues

## Performance Considerations

- Images are cached locally to reduce API calls
- Cache is automatically managed (24-hour expiration)
- Fallback images ensure UI consistency
- Background downloads don't block UI

## Troubleshooting

### Images Not Loading
1. Check network connectivity
2. Verify API endpoint is accessible
3. Check image URLs in API response
4. Clear cache and retry

### Cache Issues
1. Check device storage space
2. Verify app permissions
3. Clear cache manually
4. Restart the app

### API Errors
1. Check API endpoint URL
2. Verify authentication token
3. Check API response format
4. Review server logs

## Future Enhancements

- **Launcher Icon Updates**: Dynamic launcher icon updates (requires platform-specific implementation)
- **Multiple Branding Sets**: Support for different branding themes
- **Real-time Updates**: WebSocket support for instant branding changes
- **A/B Testing**: Support for testing different branding variants

## Support

For issues or questions about the dynamic branding system, please refer to the API documentation or contact the development team.

## Changelog

### Version 1.0.0
- Initial implementation of dynamic branding system
- Support for app icons and logos
- Automatic caching with 24-hour expiration
- Fallback support for offline scenarios
- Comprehensive error handling
- Demo screen for testing
