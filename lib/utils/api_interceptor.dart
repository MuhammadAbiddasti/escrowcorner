import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'rate_limiter.dart';

class ApiInterceptor {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _defaultMaxRetries = 3;
  static const Duration _defaultRetryDelay = Duration(seconds: 2);
  
  /// Make a rate-limited GET request
  static Future<http.Response?> get({
    required String key,
    required Uri url,
    Map<String, String>? headers,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  }) async {
    return _makeRequest(
      key: key,
      requestType: 'GET',
      url: url,
      headers: headers,
      timeout: timeout,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }
  
  /// Make a rate-limited POST request
  static Future<http.Response?> post({
    required String key,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  }) async {
    return _makeRequest(
      key: key,
      requestType: 'POST',
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }
  
  /// Make a rate-limited PUT request
  static Future<http.Response?> put({
    required String key,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  }) async {
    return _makeRequest(
      key: key,
      requestType: 'PUT',
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }
  
  /// Make a rate-limited DELETE request
  static Future<http.Response?> delete({
    required String key,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  }) async {
    return _makeRequest(
      key: key,
      requestType: 'DELETE',
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }
  
  /// Internal method to make rate-limited requests
  static Future<http.Response?> _makeRequest({
    required String key,
    required String requestType,
    required Uri url,
    Map<String, String>? headers,
    Object? body,
    Duration timeout = _defaultTimeout,
    int maxRetries = _defaultMaxRetries,
    Duration retryDelay = _defaultRetryDelay,
  }) async {
    // Check rate limiting
    if (!RateLimiter.canMakeRequest(key: key)) {
      _showRateLimitError(key);
      return null;
    }
    
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        http.Response response;
        
        switch (requestType) {
          case 'GET':
            response = await http.get(url, headers: headers).timeout(timeout);
            break;
          case 'POST':
            response = await http.post(url, headers: headers, body: body).timeout(timeout);
            break;
          case 'PUT':
            response = await http.put(url, headers: headers, body: body).timeout(timeout);
            break;
          case 'DELETE':
            response = await http.delete(url, headers: headers, body: body).timeout(timeout);
            break;
          default:
            throw Exception('Unsupported request type: $requestType');
        }
        
        // Handle rate limiting response
        if (response.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            _showRateLimitError(key);
            return null;
          }
          
          // Wait before retrying
          await Future.delayed(retryDelay * retryCount);
          continue;
        }
        
        return response;
        
      } catch (e) {
        retryCount++;
        
        if (retryCount >= maxRetries) {
          _showError('Request failed after $maxRetries attempts: $e');
          return null;
        }
        
        // Wait before retrying
        await Future.delayed(retryDelay * retryCount);
      }
    }
    
    return null;
  }
  
  /// Show rate limit error
  static void _showRateLimitError(String key) {
    final remainingTime = RateLimiter.getTimeUntilNextRequest(key);
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    
    String message;
    if (minutes > 0) {
      message = 'Too many requests. Please wait $minutes minute${minutes > 1 ? 's' : ''} before trying again.';
    } else {
      message = 'Too many requests. Please wait $seconds second${seconds > 1 ? 's' : ''} before trying again.';
    }
    
    Get.snackbar(
      'Rate Limit Exceeded',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }
  
  /// Show general error
  static void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }
  
  /// Clear rate limiting for a specific key
  static void clearRateLimit(String key) {
    RateLimiter.clearKey(key);
  }
  
  /// Clear all rate limiting
  static void clearAllRateLimits() {
    RateLimiter.clearAll();
  }
  
  /// Get remaining requests for a key
  static int getRemainingRequests(String key) {
    return RateLimiter.getRemainingRequests(key);
  }
  
  /// Get time until next request is allowed
  static Duration getTimeUntilNextRequest(String key) {
    return RateLimiter.getTimeUntilNextRequest(key);
  }
}
