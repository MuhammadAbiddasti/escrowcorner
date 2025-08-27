import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../widgets/custom_token/constant_token.dart';
import '../../widgets/custom_api_url/constant_url.dart';
import '../screens/dashboard/dashboard_controller.dart' as dash;
import '../controller/home_controller.dart' as home;
import '../screens/user_profile/user_profile_controller.dart';

class WalletController extends GetxController {
  var walletBalance = RxString('--.--');
  var mtnBalance = RxString('0.00');
  var orangeBalance = RxString('0.00');
  var currencies = <Currency>[].obs;
  var selectedCurrency = Rx<Currency?>(null);
  var walletCurrencies = <WalletCurrency>[].obs;
  var wallletCurrency = Rx<WalletCurrency?>(null);
  var wallets = <dynamic>[].obs; // Changed to <dynamic> to match API data type
  var isLoading = false.obs;
  var token = ''.obs;
  var walletGatewayDetails = <dynamic>[].obs;

final home.HomeController controller = Get.put(home.HomeController());
  final userController = Get.put(UserProfileController());


  @override
  void onInit() {
    super.onInit();
    //_initializeTokenAndFetchCurrencies(context);
    //fetchWalletCurrencies();
    fetchWalletBalance( userController.walletId.value);
    walletBalance.value;

  }
// initialize Token And Fetch Currencies
  Future<void> _initializeTokenAndFetchCurrencies(BuildContext context) async {
    try {
      isLoading(true);
      String? fetchedToken = await getToken();
      if (fetchedToken != null) {
        token.value = fetchedToken;
        print("Token fetched and assigned: $fetchedToken"); // Debug print
      } else {
        //Get.snackbar('Error', 'Token is null');
      }
    }
    catch(e) {
      print("Initialization error: $e");
      Get.snackbar('Error', 'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
    }
    finally{
      isLoading(false);
    }

    await fetchCurrencies(context);
    isLoading(false);
  }
// Method to get Currencies
  Future<void> fetchCurrencies(BuildContext context) async {
    String? token = await getToken();
    if (token == null) {
      //Get.snackbar('Error', 'Create wallet Token is null');
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/getCurrencies');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    };

    try {
      print("Fetching currencies...");

      final response = await http.get(url, headers: headers);
      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");
      if (response.statusCode != 200) {
        Get.snackbar('Error', 'Wallet API: Failed to fetch currencies (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Print the parsed data to understand its structure
        print("Parsed Data: $data");

        if (data['data'] != null && data['data'] is List) {
          final currenciesList = data['data'] as List<dynamic>;
          currencies.value = currenciesList.map((json) => Currency.fromJson(json)).toList();

          // Set default selected currency
          if (currencies.isNotEmpty) {
            setSelectedCurrency(context, currencies.first);
            print("Wallet Currencies: ${currencies.length}");
          }
        } else {
          print("Unexpected data format: ${data.runtimeType}");
          Get.snackbar('Error', 'Wallet API: Invalid data format');
          //Get.snackbar('Error', 'Invalid data format');
        }
      } else {
        print("Failed to fetch currencies: ${response.statusCode} - ${response.body}");
        //Get.snackbar('Error', 'Failed to fetch currencies');
      }
    } catch (e) {
      print("Error fetching currencies: $e");
      Get.snackbar('Error', 'Wallet API: $e');
      //Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedCurrency(BuildContext context, Currency currency) {
    selectedCurrency.value = currency;
    fetchBalanceForSelectedCurrency(context);
  }

  void fetchBalanceForSelectedCurrency(BuildContext context) {
    if (selectedCurrency.value == null) {
      print("No currency selected");
      return;
    }

    final selectedCurrencyId = selectedCurrency.value!.id;
    print("Fetching balance for selected currency: ${selectedCurrency.value!.name}");

    // Debug: Print wallets list and selected currency
    print("Wallets: $wallets");
    print("Selected Currency ID: $selectedCurrencyId");

    // Find wallet ID for the selected currency

    //final walletId = wallet['id'].toString();
    //print("Matched wallet ID: $walletId for currency: ${selectedCurrency.value!.name}");

    // Fetch wallet balance
    fetchWalletBalance( userController.walletId.value);
  }

// Method to get Wallet Balance
  Future<void> fetchWalletBalance(String walletId) async {
    if (walletId.isEmpty) {
      print("Wallet ID is empty. Cannot fetch balance.");
      //Get.snackbar('Error', 'Invalid wallet ID');
      return;
    }

    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/walletBalance?wallet_id=$walletId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      print("Fetching wallet balance for wallet ID: $walletId");
      final response = await http.get(url, headers: headers);
      print('Wallet API status:  [33m${response.statusCode} [0m');
      print('Wallet API body:  [36m${response.body} [0m');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Wallet API parsed: $data');
        if (data['balance'] != null && data['currency_symbol'] != null) {
          String balanceStr = data['balance'].toString().replaceAll(RegExp(r'[^ -9.]'), '');
          walletBalance.value = '${data['currency_symbol']} $balanceStr';
          print("Balance fetched:  [32m${walletBalance.value} [0m");
        } else {
          print("Invalid response from API: $data");
          Get.snackbar('Error', 'Wallet API: Invalid response from API');
        }
        walletGatewayDetails.clear();
        if (data['wallet_gateway_array'] != null) {
          if (data['wallet_gateway_array'] is List) {
            for (var item in data['wallet_gateway_array']) {
              if (item['gateway_name'] != null && item['gateway_balance'] != null) {
                walletGatewayDetails.add({
                  'name': item['gateway_name'].toString(),
                  'balance': item['gateway_balance'].toString(),
                });
              }
            }
          } else if (data['wallet_gateway_array'] is Map) {
            data['wallet_gateway_array'].forEach((key, value) {
              if (value is Map && value['gateway_name'] != null && value['gateway_balance'] != null) {
                walletGatewayDetails.add({
                  'name': value['gateway_name'].toString(),
                  'balance': value['gateway_balance'].toString(),
                });
              }
            });
          }
        }
      } else {
        print("Failed to fetch wallet balance: ${response.statusCode} - ${response.body}");
        Get.snackbar('Error', 'Wallet API: Failed to fetch wallet balance (Status: ${response.statusCode}})');
        //Get.snackbar('Error', 'Failed to fetch wallet balance: ${response.statusCode}');
        mtnBalance.value = '0.00';
        orangeBalance.value = '0.00';
        walletGatewayDetails.clear();
      }
    } catch (e) {
      print("Error fetching wallet balance: $e");
      Get.snackbar('Error', 'Wallet API: $e');
      //Get.snackbar('Error', 'An error occurred: $e');
      mtnBalance.value = '0.00';
      orangeBalance.value = '0.00';
      walletGatewayDetails.clear();
    } finally {
      isLoading(false);
    }
  }


// Method to get Wallet Currencies
  Future<void> fetchWalletCurrencies() async {
    String? token = await getToken();
    if(token==null){
      Get.snackbar("Error", "Token is Null",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      isLoading.value = false;
      return;
    }

    final url = Uri.parse('$baseUrl/api/getCurrencies');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token}',
    };

    try {
      final response = await http.get(url, headers: headers);
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print("Response data: $data");

        if (data['success'] == true && data['data'] != null && data['data'] is List) {
          final currenciesList = data['data'] as List<dynamic>;
          walletCurrencies.value = currenciesList.map((json) => WalletCurrency.fromJson(json)).toList();
          //print("Wallet Currencies length: ${walletCurrencies.length}");

          if (walletCurrencies.isNotEmpty) {
            //setWalletCurrency(walletCurrencies.first);
            //print("First Wallet Currency: ${walletCurrencies.first}");
          } else {
            Get.snackbar('Info', 'No currencies available',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,);
          }
        } else {
          //Get.snackbar('Error', 'Invalid data format');
        }
      } else {
        print("Failed to fetch currencies: ${response.statusCode} - ${response.body}");
        Get.snackbar('Error', 'Failed to fetch currencies. Status code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,);
      }
    } catch (e) {
      print("Error fetching currencies: $e");
      //Get.snackbar('Error', 'An error occurred while fetching currencies: $e');
    } finally {
      isLoading(false);
    }
  }
  void setWalletCurrency(WalletCurrency walletCurrency) {
    wallletCurrency.value = walletCurrency;
  }

  Future<Map<String, dynamic>?> createWallet(int currencyId,
      int accountIdentifierMechanismId) async {
    isLoading.value = true;
    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Create wallet Token is null',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,);
      isLoading.value = false;
      return null;
    }

    final url = Uri.parse(
        '$baseUrl/api/create_wallet?currency_id=$currencyId&account_identifier_mechanism_id=$accountIdentifierMechanismId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Don't show snackbar here, let the caller handle it
          print('Wallet created successfully');
        } else {
          print('Wallet creation failed: ${data['message']}');
        }
        // Return the response data
        return data;
      } else {
        print('Failed to create wallet: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to create wallet (Status: ${response.statusCode})'
        };
      }
    } catch (e) {
      print("An error occurred: $e");
      return {
        'success': false,
        'message': 'An error occurred: $e'
      };
    } finally {
      isLoading.value = false;
    }
  }
}

// Model Class for Get Currencies
class Currency {
  final int id;
  final String name;
  String symbol;
  String code;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.code,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] != null ? json['id'] as int : throw FormatException("Missing id"),
      name: json['name'] != null ? json['name'] as String : throw FormatException("Missing name"),
      symbol: json['symbol'] != null ? json['symbol'] as String : throw FormatException("Missing symbol"),
      code: json['code'] != null ? json['code'] as String : throw FormatException("Missing code"),
    );
  }
}
// Model Class for Get Wallet Currencies
class WalletCurrency {
  final int id;
  final String name;
  String symbol;

  WalletCurrency({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory WalletCurrency.fromJson(Map<String, dynamic> json) {
    return WalletCurrency(
      id: json['id'] != null ? json['id'] as int : throw FormatException("Missing id"),
      name: json['name'] != null ? json['name'] as String : throw FormatException("Missing name"),
      symbol: json['symbol'] != null ? json['symbol'] as String : throw FormatException("Missing symbol"),
    );
  }
}



//Future<void> fetchCurrencies() async {
//     String? token = await getToken();
//     if (token == null) {
//       Get.snackbar('Error', 'Create wallet Token is null');
//       isLoading.value = false;
//       return;
//     }
//
//     final url = Uri.parse('$baseUrl/api/getCurrencies');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer ${token}',
//     };
//
//     try {
//       print("Fetching currencies...");
//
//       final response = await http.get(url, headers: headers);
//       print("Response Status Code: ${response.statusCode}");
//       print("Response Headers: ${response.headers}");
//       print("Response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         // Print the parsed data to understand its structure
//         print("Parsed Data: $data");
//
//         if (data['data'] != null && data['data'] is List) {
//           final currenciesList = data['data'] as List<dynamic>;
//           currencies.value = currenciesList.map((json) => Currency.fromJson(json)).toList();
//
//           // Set default selected currency
//           if (currencies.isNotEmpty) {
//             setSelectedCurrency(currencies.first);
//             print("Wallet Currencies: ${currencies.length}");
//           }
//         } else {
//           print("Unexpected data format: ${data.runtimeType}");
//           Get.snackbar('Error', 'Invalid data format');
//         }
//       } else {
//         print("Failed to fetch currencies: ${response.statusCode} - ${response.body}");
//         Get.snackbar('Error', 'Failed to fetch currencies');
//       }
//     } catch (e) {
//       print("Error fetching currencies: $e");
//       Get.snackbar('Error', 'An error occurred: $e');
//     } finally {
//       isLoading(false);
//     }
//   }
//   void setSelectedCurrency(Currency currency) {
//     selectedCurrency.value = currency;
//     fetchBalanceForSelectedCurrency();
//   }
//   void fetchBalanceForSelectedCurrency() {
//     if (selectedCurrency.value == null) {
//       print("No currency selected");
//       return;
//     }
//
//     print("Fetching balance for selected currency: ${selectedCurrency.value!.name}");
//     String? walletIdForCurrency;
//
//     // Find wallet ID for the selected currency
//     for (var wallet in wallets) {
//       int walletCurrencyId = int.tryParse(wallet['currency_id'].toString()) ?? -1;
//       print("Checking wallet: ${wallet['id']} with currency_id: $walletCurrencyId");
//       if (walletCurrencyId == selectedCurrency.value!.id) {
//         walletIdForCurrency = wallet['id'].toString();
//         print("Matched wallet ID: $walletIdForCurrency for currency: ${selectedCurrency.value!.name}");
//         break;
//       }
//     }
//
//     // If wallet ID is not found, notify the user
//     if (walletIdForCurrency == null || walletIdForCurrency.isEmpty) {
//       print('No wallet found for selected currency: ${selectedCurrency.value!.name}');
//       Get.snackbar('Error', 'No wallet found for the selected currency');
//       walletBalance.value; // Clear balance
//       return;
//     }
//
//     // Fetch wallet balance
//     fetchWalletBalance(walletIdForCurrency);
//   }
// // Method to get Wallet Balance
//   Future<void> fetchWalletBalance(String walletId) async {
//     String? token = await getToken();
//     if (token == null) {
//       Get.snackbar('Error', 'Token is null');
//       isLoading.value = false;
//       return;
//     }
//
//     final url = Uri.parse('$baseUrl/api/walletBalance?wallet_id=$walletId');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//
//     try {
//       print("Fetching wallet balance for wallet ID: $walletId");
//       final response = await http.get(url, headers: headers);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['balance'] != null && data['currency_symbol'] != null) {
//           String balanceStr = data['balance'].toString().replaceAll(RegExp(r'[^\d.]'), '');
//           walletBalance.value = '${data['currency_symbol']} $balanceStr';
//           print("Balance fetched: ${walletBalance.value}");
//         } else {
//           print("Invalid response from API: $data");
//           Get.snackbar('Error', 'Invalid response from API');
//         }
//       } else {
//         print("Failed to fetch wallet balance: ${response.statusCode} - ${response.body}");
//         Get.snackbar('Error', 'Failed to fetch wallet balance: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error fetching wallet balance: $e");
//       Get.snackbar('Error', 'An error occurred: $e');
//     } finally {
//       isLoading(false);
//     }
//   }