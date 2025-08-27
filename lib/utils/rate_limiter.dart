import 'dart:async';

class RateLimiter {
  static final Map<String, Timer> _timers = {};
  static final Map<String, DateTime> _lastRequestTimes = {};
  static final Map<String, int> _requestCounts = {};
  
  // Default rate limiting settings
  static const Duration _defaultDebounceDelay = Duration(milliseconds: 300);
  static const Duration _defaultThrottleDelay = Duration(milliseconds: 1000);
  static const int _defaultMaxRequestsPerMinute = 60;
  
  /// Debounce function calls - only execute after delay has passed
  static Future<T?> debounce<T>({
    required String key,
    required Future<T> Function() function,
    Duration delay = _defaultDebounceDelay,
  }) async {
    // Cancel existing timer
    _timers[key]?.cancel();
    
    // Create new timer
    _timers[key] = Timer(delay, () {});
    
    // Wait for timer to complete
    await Future.delayed(delay);
    
    // Check if this is still the latest request
    if (_timers[key]?.isActive == true) {
      return await function();
    }
    
    return null;
  }
  
  /// Debounce void function calls - only execute after delay has passed
  static Future<void> debounceVoid({
    required String key,
    required Future<void> Function() function,
    Duration delay = _defaultDebounceDelay,
  }) async {
    // Cancel existing timer
    _timers[key]?.cancel();
    
    // Create new timer
    _timers[key] = Timer(delay, () {});
    
    // Wait for timer to complete
    await Future.delayed(delay);
    
    // Check if this is still the latest request
    if (_timers[key]?.isActive == true) {
      await function();
    }
  }
  
  /// Throttle function calls - execute at most once per delay period
  static Future<T?> throttle<T>({
    required String key,
    required Future<T> Function() function,
    Duration delay = _defaultThrottleDelay,
  }) async {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[key];
    
    if (lastRequest == null || now.difference(lastRequest) >= delay) {
      _lastRequestTimes[key] = now;
      return await function();
    }
    
    return null;
  }
  
  /// Rate limit function calls - check if we're within limits
  static bool canMakeRequest({
    required String key,
    int maxRequestsPerMinute = _defaultMaxRequestsPerMinute,
  }) {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[key];
    
    if (lastRequest == null) {
      _lastRequestTimes[key] = now;
      _requestCounts[key] = 1;
      return true;
    }
    
    // Reset counter if more than a minute has passed
    if (now.difference(lastRequest) >= Duration(minutes: 1)) {
      _requestCounts[key] = 1;
      _lastRequestTimes[key] = now;
      return true;
    }
    
    // Check if we're within limits
    final currentCount = _requestCounts[key] ?? 0;
    if (currentCount < maxRequestsPerMinute) {
      _requestCounts[key] = currentCount + 1;
      return true;
    }
    
    return false;
  }
  
  /// Clear all rate limiting data for a specific key
  static void clearKey(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
    _lastRequestTimes.remove(key);
    _requestCounts.remove(key);
  }
  
  /// Clear all rate limiting data
  static void clearAll() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _lastRequestTimes.clear();
    _requestCounts.clear();
  }
  
  /// Get remaining requests allowed for a key
  static int getRemainingRequests(String key) {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[key];
    
    if (lastRequest == null) {
      return _defaultMaxRequestsPerMinute;
    }
    
    // Reset counter if more than a minute has passed
    if (now.difference(lastRequest) >= Duration(minutes: 1)) {
      return _defaultMaxRequestsPerMinute;
    }
    
    final currentCount = _requestCounts[key] ?? 0;
    return _defaultMaxRequestsPerMinute - currentCount;
  }
  
  /// Get time until next request is allowed
  static Duration getTimeUntilNextRequest(String key) {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[key];
    
    if (lastRequest == null) {
      return Duration.zero;
    }
    
    final timeSinceLastRequest = now.difference(lastRequest);
    if (timeSinceLastRequest >= Duration(minutes: 1)) {
      return Duration.zero;
    }
    
    return Duration(minutes: 1) - timeSinceLastRequest;
  }
}
