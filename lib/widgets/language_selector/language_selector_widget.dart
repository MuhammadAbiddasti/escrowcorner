import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/controller/language_controller.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final bool showAsDropdown;
  final bool showAsBottomSheet;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const LanguageSelectorWidget({
    Key? key,
    this.showAsDropdown = false,
    this.showAsBottomSheet = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    if (showAsDropdown) {
      return _buildDropdownSelector(languageController);
    } else if (showAsBottomSheet) {
      return _buildBottomSheetTrigger(context, languageController);
    } else {
      return _buildIconButton(context, languageController);
    }
  }

  // Dropdown selector
  Widget _buildDropdownSelector(LanguageController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          width: width ?? 120,
          height: height ?? 40,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      return Container(
        width: width ?? 120,
        height: height ?? 40,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Language>(
            value: controller.selectedLanguage.value,
            isExpanded: true,
            icon: Icon(Icons.language, color: textColor ?? Colors.grey[600]),
            dropdownColor: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
            items: controller.languages.map((Language language) {
              return DropdownMenuItem<Language>(
                value: language,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    language.name,
                    style: TextStyle(
                      color: textColor ?? Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (Language? newValue) {
              if (newValue != null) {
                controller.changeLanguage(newValue);
              }
            },
          ),
        ),
      );
    });
  }

  // Icon button that opens bottom sheet
  Widget _buildIconButton(BuildContext context, LanguageController controller) {
    return IconButton(
      onPressed: () => _showLanguageBottomSheet(context, controller),
      icon: Icon(
        Icons.language,
        color: textColor ?? Colors.white,
        size: 24,
      ),
      tooltip: 'Change Language',
    );
  }

  // Bottom sheet trigger
  Widget _buildBottomSheetTrigger(BuildContext context, LanguageController controller) {
    return InkWell(
      onTap: () => _showLanguageBottomSheet(context, controller),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor ?? Colors.white, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: textColor ?? Colors.white,
              size: 16,
            ),
            SizedBox(width: 4),
            Obx(() => Text(
              controller.getCurrentLanguageName(),
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: textColor ?? Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Show language selection bottom sheet
  void _showLanguageBottomSheet(BuildContext context, LanguageController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: EdgeInsets.all(20),
                                  child: Text(
                    'select_language'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
              ),
              
              // Language list
              Obx(() {
                if (controller.isLoading.value) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (controller.hasError.value) {
                  return Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'failed_to_load_languages'.tr,
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.refreshLanguages(),
                            child: Text('retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.languages.length,
                    itemBuilder: (context, index) {
                      final language = controller.languages[index];
                      final isSelected = controller.selectedLanguage.value?.id == language.id;
                      
                      return ListTile(
                        leading: Icon(
                          Icons.language,
                          color: isSelected ? Colors.blue : Colors.grey[600],
                        ),
                        title: Text(
                          language.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          language.locale.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          controller.changeLanguage(language);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                );
              }),
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// Quick language switcher for app bar
class QuickLanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LanguageSelectorWidget(
      showAsBottomSheet: true,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    );
  }
}

// Dropdown language selector for forms
class DropdownLanguageSelector extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;

  const DropdownLanguageSelector({
    Key? key,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LanguageSelectorWidget(
      showAsDropdown: true,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

// Simple translation widget for displaying translated text
class TranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? locale;

  const TranslatedText({
    Key? key,
    required this.translationKey,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (controller) {
        final translatedText = controller.getTranslation(translationKey, locale: locale);
        return Text(
          translatedText,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

// Obx version for reactive updates
class ReactiveTranslatedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? locale;

  const ReactiveTranslatedText({
    Key? key,
    required this.translationKey,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<LanguageController>();
      final translatedText = controller.getTranslation(translationKey, locale: locale);
      return Text(
        translatedText,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    });
  }
}
