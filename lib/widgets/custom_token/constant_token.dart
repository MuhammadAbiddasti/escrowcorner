 import 'package:shared_preferences/shared_preferences.dart';

 Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');  // Retrieve the token
  print('Retrieved Token: $token');
  return token;  // Return the token or null
 }


 // Function to save walletId
 Future<void> saveWalletId(String walletId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('wallet_id', walletId);
 }

 // Function to get walletId
 Future<String?> getWalletId() async {
  final prefs = await SharedPreferences.getInstance();
  String? walletId = prefs.getString('wallet_id');
  print('Retrieved Wallet ID: $walletId');  // Log to confirm retrieval
  return walletId;
 }
 // Future<bool> toggleFingerprintAuthentication(BuildContext context) async {
 //   try {
 //     // Fetch user info first to ensure the fingerprint token is available
 //     await fetchUserInfo();
 //
 //     SharedPreferences prefs = await SharedPreferences.getInstance();
 //     String? token = prefs.getString('token');
 //
 //     String? fingerPrintToken = await getToken();
 //     //String? currentToken = await getStoreToken();
 //
 //     // Retrieve stored tokens and status from secure storage
 //     //final String? currentToken = await secureStorage.read(key: 'token');
 //     final String? fingerprintStatus = await secureStorage.read(key: 'finger_print');
 //
 //     // Treat null fingerprint status as disabled
 //     final String currentStatus = fingerprintStatus ?? 'disabled';
 //
 //     if (fingerPrintToken == null) {
 //       ScaffoldMessenger.of(context).showSnackBar(
 //         const SnackBar(
 //           content: Text('No session or fingerprint token found. Please log in first.'),
 //           backgroundColor: Colors.red,
 //         ),
 //       );
 //       return false;
 //     }
 //     print("Current Token: $token");
 //     // Determine the new status based on the current status
 //     final bool isCurrentlyEnabled = currentStatus == 'enabled';
 //     final bool newStatus = !isCurrentlyEnabled; // Toggle status
 //
 //     // Prompt user for authentication
 //     final bool isAuthenticated = await _localAuth.authenticate(
 //       localizedReason: newStatus
 //           ? 'Please authenticate to enable fingerprint login'
 //           : 'Please authenticate to disable fingerprint login',
 //       options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
 //     );
 //
 //     if (!isAuthenticated) {
 //       ScaffoldMessenger.of(context).showSnackBar(
 //         SnackBar(
 //           content: Text(newStatus
 //               ? 'Fingerprint authentication failed for enabling.'
 //               : 'Fingerprint authentication failed for disabling.'),
 //           backgroundColor: Colors.red,
 //         ),
 //       );
 //       return false;
 //     }
 //
 //     // Make the API call to update fingerprint status
 //     final String apiUrl = "$baseUrl/api/enable_finger_print";
 //     final response = await http.post(
 //       Uri.parse(apiUrl),
 //       headers: {
 //         "Content-Type": "application/json",
 //         "Authorization": "Bearer $token",
 //       },
 //       body: jsonEncode({
 //         "finger_print": newStatus ? "enabled" : "disabled",
 //         "finger_print_token": fingerPrintToken,
 //       }),
 //     );
 //
 //     final responseData = jsonDecode(response.body);
 //
 //     if (response.statusCode == 200 || response.statusCode == 201) {
 //       // Update the local storage for fingerprint enabled status
 //       await secureStorage.write(
 //           key: 'fingerprintEnabled', value: newStatus ? 'enabled' : 'disabled');
 //
 //       ScaffoldMessenger.of(context).showSnackBar(
 //         SnackBar(
 //           content: Text(newStatus
 //               ? 'Fingerprint authentication enabled successfully!'
 //               : 'Fingerprint authentication disabled successfully!'),
 //           backgroundColor: Colors.green,
 //         ),
 //       );
 //
 //       // If fingerprint is enabled, store the fingerprint token
 //       if (newStatus) {
 //         String fingerToken = responseData['finger_print_token'];
 //         await _storeFingerprintToken(fingerToken);
 //       }
 //
 //       return true;
 //     } else {
 //       // Parse and show error message from the server response
 //       final String errorMessage = responseData['error'] ?? 'Failed to update server.';
 //       ScaffoldMessenger.of(context).showSnackBar(
 //         SnackBar(
 //           content: Text('Error: $errorMessage'),
 //           backgroundColor: Colors.red,
 //         ),
 //       );
 //     }
 //   } catch (e) {
 //     print(e);
 //     ScaffoldMessenger.of(context).showSnackBar(
 //       const SnackBar(
 //         content: Text(' An error occurred while toggling fingerprint setup.'),
 //         backgroundColor: Colors.red,
 //       ),
 //     );
 //   }
 //
 //   return false;
 // }