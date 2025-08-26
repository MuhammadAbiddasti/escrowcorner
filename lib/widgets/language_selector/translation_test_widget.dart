import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/controller/language_controller.dart';

/// A test widget to demonstrate and verify that translations are working correctly
class TranslationTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Translation Test',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Test different translation keys
          _buildTranslationTest(languageController, 'get_started'),
          _buildTranslationTest(languageController, 'home'),
          _buildTranslationTest(languageController, 'register'),
          _buildTranslationTest(languageController, 'log_in'),
          _buildTranslationTest(languageController, 'dashboard'),
          _buildTranslationTest(languageController, 'settings'),
          _buildTranslationTest(languageController, 'logout'),
          
          // Test a key that doesn't exist (should return the key itself)
          _buildTranslationTest(languageController, 'non_existent_key'),
          
          SizedBox(height: 16),
          
          // Show current language
          Obx(() => Text(
            'Current Language: ${languageController.getCurrentLanguageName()} (${languageController.getCurrentLanguageLocale()})',
            style: TextStyle(fontWeight: FontWeight.w500),
          )),
          
          SizedBox(height: 8),
          
          // Show number of cached translations
          Text(
            'Available translations: ${languageController.getAvailableTranslationKeys().length}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationTest(LanguageController controller, String key) {
    final translation = controller.getTranslation(key);
    final isTranslated = translation != key;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '"$key"',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.grey,
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              '"$translation"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTranslated ? FontWeight.w500 : FontWeight.normal,
                color: isTranslated ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
          Icon(
            isTranslated ? Icons.check_circle : Icons.error,
            size: 16,
            color: isTranslated ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
