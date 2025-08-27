# Rate Limiting Solution for "Too Many API Request" Error

This solution implements comprehensive rate limiting to prevent the "Too Many API Request" error that occurs when users interact with the app too quickly.

## 🚀 Features

### 1. **Rate Limiter Utility** (`lib/utils/rate_limiter.dart`)
- **Debouncing**: Prevents multiple rapid function calls
- **Throttling**: Limits function execution frequency
- **Request Counting**: Tracks API requests per minute
- **Configurable Limits**: Customizable delays and request limits

### 2. **API Interceptor** (`lib/utils/api_interceptor.dart`)
- **Global Rate Limiting**: Applies to all HTTP requests
- **Automatic Retries**: Handles 429 responses with exponential backoff
- **Unified Interface**: Simple methods for GET, POST, PUT, DELETE
- **Error Handling**: User-friendly error messages

### 3. **Controller Integration**
- **Merchant Controller**: Rate-limited API calls
- **Transfer In Screen**: Debounced submit button
- **Smart Loading States**: Prevents multiple simultaneous requests

## 📱 How It Works

### **Debouncing (Submit Buttons)**
```dart
// Prevents rapid button clicks
RateLimiter.debounce(
  key: 'submit_transfer_in',
  function: _handleTransferIn,
  delay: Duration(milliseconds: 500),
);
```

### **Request Rate Limiting**
```dart
// Check if request is allowed
if (!RateLimiter.canMakeRequest(key: 'fetchMerchants')) {
  // Show rate limit message
  return;
}
```

### **API Interceptor Usage**
```dart
// Instead of direct http.get()
final response = await ApiInterceptor.get(
  key: 'fetch_data',
  url: Uri.parse('$baseUrl/api/endpoint'),
  headers: {'Authorization': 'Bearer $token'},
);
```

## ⚙️ Configuration

### **Default Settings**
- **Debounce Delay**: 300ms
- **Throttle Delay**: 1000ms (1 second)
- **Max Requests per Minute**: 60
- **Request Timeout**: 30 seconds
- **Max Retries**: 3
- **Retry Delay**: 2 seconds

### **Custom Settings**
```dart
// Custom debounce delay
RateLimiter.debounce(
  key: 'custom_key',
  function: myFunction,
  delay: Duration(milliseconds: 1000), // 1 second
);

// Custom rate limit
RateLimiter.canMakeRequest(
  key: 'custom_key',
  maxRequestsPerMinute: 30, // 30 requests per minute
);
```

## 🔧 Implementation Examples

### **1. Button Debouncing**
```dart
ElevatedButton(
  onPressed: () {
    RateLimiter.debounce(
      key: 'button_action',
      function: () => performAction(),
      delay: Duration(milliseconds: 500),
    );
  },
  child: Text('Submit'),
)
```

### **2. API Request Rate Limiting**
```dart
Future<void> fetchData() async {
  // Check rate limit before making request
  if (!RateLimiter.canMakeRequest(key: 'fetch_data')) {
    Get.snackbar('Rate Limit', 'Too many requests. Please wait.');
    return;
  }
  
  // Make API request
  final response = await http.get(url);
  // Handle response...
}
```

### **3. Using API Interceptor**
```dart
Future<void> fetchData() async {
  final response = await ApiInterceptor.get(
    key: 'fetch_data',
    url: Uri.parse('$baseUrl/api/data'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response != null) {
    // Handle successful response
  }
}
```

## 🎯 Best Practices

### **1. Use Unique Keys**
```dart
// Good: Unique keys for different operations
RateLimiter.debounce(key: 'fetch_merchants', function: fetchMerchants);
RateLimiter.debounce(key: 'fetch_transactions', function: fetchTransactions);

// Bad: Same key for different operations
RateLimiter.debounce(key: 'api_call', function: fetchMerchants);
RateLimiter.debounce(key: 'api_call', function: fetchTransactions);
```

### **2. Appropriate Delays**
```dart
// Submit buttons: 300-500ms
RateLimiter.debounce(key: 'submit', function: submit, delay: Duration(milliseconds: 500));

// Search inputs: 300ms
RateLimiter.debounce(key: 'search', function: search, delay: Duration(milliseconds: 300));

// Navigation: 100ms
RateLimiter.debounce(key: 'navigate', function: navigate, delay: Duration(milliseconds: 100));
```

### **3. Clear Rate Limits When Needed**
```dart
// Clear specific key
RateLimiter.clearKey('fetch_data');

// Clear all rate limits (use sparingly)
RateLimiter.clearAll();
```

## 🚨 Error Handling

### **Rate Limit Exceeded**
- Shows user-friendly message
- Displays remaining wait time
- Prevents further requests until limit resets

### **Network Errors**
- Automatic retries with exponential backoff
- User notification after max retries
- Graceful degradation

### **Timeout Handling**
- Configurable timeout periods
- Automatic cancellation of slow requests
- User feedback for long operations

## 📊 Monitoring

### **Check Remaining Requests**
```dart
final remaining = RateLimiter.getRemainingRequests('fetch_data');
print('Remaining requests: $remaining');
```

### **Check Wait Time**
```dart
final waitTime = RateLimiter.getTimeUntilNextRequest('fetch_data');
print('Wait time: ${waitTime.inSeconds} seconds');
```

## 🔄 Migration Guide

### **Before (Direct HTTP calls)**
```dart
final response = await http.get(url);
```

### **After (Rate Limited)**
```dart
// Option 1: Manual rate limiting
if (RateLimiter.canMakeRequest(key: 'fetch_data')) {
  final response = await http.get(url);
}

// Option 2: Using API Interceptor
final response = await ApiInterceptor.get(
  key: 'fetch_data',
  url: url,
);
```

## 🎉 Benefits

1. **No More Rate Limit Errors**: Prevents "Too Many API Request" errors
2. **Better User Experience**: Smooth interactions without interruptions
3. **Server Protection**: Reduces server load from rapid requests
4. **Automatic Retries**: Handles temporary failures gracefully
5. **Configurable**: Easy to adjust for different use cases
6. **Performance**: Prevents unnecessary API calls

## 🐛 Troubleshooting

### **Still Getting Rate Limit Errors?**
1. Check if you're using unique keys for different operations
2. Verify the rate limit settings are appropriate for your use case
3. Ensure you're not bypassing the rate limiter with direct HTTP calls
4. Check server-side rate limiting settings

### **Performance Issues?**
1. Reduce debounce delays for better responsiveness
2. Increase rate limits if server can handle more requests
3. Use throttling instead of debouncing for continuous operations
4. Monitor request patterns and adjust accordingly

## 📞 Support

If you encounter issues with the rate limiting system:
1. Check the console logs for rate limit messages
2. Verify your rate limiting configuration
3. Test with different delay values
4. Ensure proper key naming conventions

---

**Note**: This system is designed to work alongside server-side rate limiting. The client-side limits provide immediate feedback and prevent unnecessary requests, while server-side limits provide the ultimate protection.
