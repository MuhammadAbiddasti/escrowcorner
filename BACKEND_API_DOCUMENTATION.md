# Dynamic Branding API Documentation

## Overview
This document describes the API endpoints required to implement dynamic branding for the Damaspay Flutter app. The app will fetch logos and icons from these endpoints and cache them locally.

## Base URL
```
https://escrowcorner.com
```

## Authentication
All endpoints require Bearer token authentication (except where noted).

## Endpoints

### 1. Get Settings (Including Branding)
**Endpoint:** `GET /api/get_setting`

**Description:** Fetches current app settings including branding configuration (logo and icon URLs).

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "app_icon": "https://escrowcorner.com/assets/images/1754390133_app_icon.jpeg",
    "site_logo": "https://escrowcorner.com/assets/logo/1754302770_logo.jpeg"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Failed to retrieve settings"
}
```

### 2. Update Branding (Admin Only)
**Endpoint:** `POST /api/admin/branding/update`

**Description:** Updates branding configuration (admin only).

**Headers:**
```
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body:**
```
logo: [file] (optional)
icon: [file] (optional)
app_name: "Damaspay" (optional)
primary_color: "#18CE0F" (optional)
secondary_color: "#0f9373" (optional)
```

**Response Format:**
```json
{
  "status": "success",
  "message": "Branding updated successfully",
  "data": {
    "logo_url": "https://escrowcorner.com/storage/branding/logo.png",
    "icon_url": "https://escrowcorner.com/storage/branding/icon.png",
    "app_name": "Damaspay",
    "primary_color": "#18CE0F",
    "secondary_color": "#0f9373",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

## Image Requirements

### Logo Requirements
- **Format:** PNG, JPG, or SVG
- **Recommended Size:** 512x256 pixels (2:1 aspect ratio)
- **Max File Size:** 2MB
- **Background:** Transparent or white background preferred

### Icon Requirements
- **Format:** PNG (preferred) or JPG
- **Size:** 512x512 pixels (square)
- **Max File Size:** 1MB
- **Background:** Transparent background preferred

## Implementation Notes

### 1. File Storage
- Store uploaded images in a public directory (e.g., `/storage/branding/`)
- Ensure proper file permissions for public access
- Implement file validation for security

### 2. Caching
- The Flutter app caches images locally for 24 hours
- Implement proper cache headers on your server
- Consider using CDN for better performance

### 3. Security
- Validate file types and sizes
- Implement rate limiting
- Use proper authentication for admin endpoints
- Sanitize file names

### 4. Fallback Strategy
- Always provide fallback URLs
- Handle missing files gracefully
- Return appropriate HTTP status codes

## Example Laravel Implementation

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class BrandingController extends Controller
{
    public function getSettings()
    {
        try {
            $settings = [
                'app_icon' => config('app.url') . '/assets/images/' . config('app.icon_filename', 'app_icon.jpeg'),
                'site_logo' => config('app.url') . '/assets/logo/' . config('app.logo_filename', 'logo.jpeg'),
                // Add other settings as needed
            ];

            return response()->json([
                'success' => true,
                'data' => $settings
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve settings'
            ], 500);
        }
    }

    public function updateBranding(Request $request)
    {
        // Validate admin permissions
        if (!auth()->user()->isAdmin()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized access'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'logo' => 'nullable|image|mimes:png,jpg,jpeg,svg|max:2048',
            'icon' => 'nullable|image|mimes:png,jpg,jpeg|max:1024',
            'app_name' => 'nullable|string|max:100',
            'primary_color' => 'nullable|string|regex:/^#[0-9A-F]{6}$/i',
            'secondary_color' => 'nullable|string|regex:/^#[0-9A-F]{6}$/i',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $branding = [];

            // Handle logo upload
            if ($request->hasFile('logo')) {
                $logoPath = $request->file('logo')->store('branding', 'public');
                $branding['logo_url'] = config('app.url') . '/storage/' . $logoPath;
            }

            // Handle icon upload
            if ($request->hasFile('icon')) {
                $iconPath = $request->file('icon')->store('branding', 'public');
                $branding['icon_url'] = config('app.url') . '/storage/' . $iconPath;
            }

            // Update other branding settings
            if ($request->filled('app_name')) {
                $branding['app_name'] = $request->app_name;
            }

            if ($request->filled('primary_color')) {
                $branding['primary_color'] = $request->primary_color;
            }

            if ($request->filled('secondary_color')) {
                $branding['secondary_color'] = $request->secondary_color;
            }

            $branding['updated_at'] = now()->toISOString();

            return response()->json([
                'status' => 'success',
                'message' => 'Branding updated successfully',
                'data' => $branding
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update branding',
                'error_code' => 'UPDATE_FAILED'
            ], 500);
        }
    }
}
```

## Routes (Laravel)

```php
// In routes/api.php
Route::get('/get_setting', [BrandingController::class, 'getSettings']);
Route::post('/admin/branding/update', [BrandingController::class, 'updateBranding'])
    ->middleware(['auth:sanctum', 'admin']);
```

## Testing

### Test the API Endpoint
```bash
# Test settings endpoint
curl -X GET "https://escrowcorner.com/api/get_setting" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# Expected response
{
  "success": true,
  "data": {
    "app_icon": "https://escrowcorner.com/assets/images/1754390133_app_icon.jpeg",
    "site_logo": "https://escrowcorner.com/assets/logo/1754302770_logo.jpeg"
  }
}
```

## Integration Steps

1. **Implement the API endpoints** on your backend
2. **Upload initial branding assets** to your server
3. **Test the endpoints** to ensure they return proper responses
4. **Update the Flutter app** to use the dynamic branding system
5. **Monitor and maintain** the branding assets

## Benefits

- **Dynamic Updates:** Change branding without app updates
- **A/B Testing:** Test different branding variations
- **Seasonal Campaigns:** Update branding for special events
- **Brand Consistency:** Ensure all users see the latest branding
- **Offline Support:** Cached images work without internet
- **Fallback Protection:** Always shows branding even if server is down 