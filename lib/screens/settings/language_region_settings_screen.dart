import 'package:flutter/material.dart';

class LanguageRegionSettingsScreen extends StatefulWidget {
  const LanguageRegionSettingsScreen({super.key});

  @override
  State<LanguageRegionSettingsScreen> createState() =>
      _LanguageRegionSettingsScreenState();
}

class _LanguageRegionSettingsScreenState
    extends State<LanguageRegionSettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedTimeZone = 'Auto';
  String _selectedNumberFormat = '1,000.00';

  final List<String> languages = ['English', 'Urdu'];
  final List<String> timeZones = [
    'Auto',
    'GMT+5 (Pakistan)',
    'GMT+0 (UTC)',
    'Manual...',
  ];
  final List<String> numberFormats = ['1,000.00', '1.000,00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language & Region Preferences")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "App Language",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedLanguage,
              items:
                  languages.map((lang) {
                    return DropdownMenuItem(value: lang, child: Text(lang));
                  }).toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),
            const SizedBox(height: 24),
            const Text(
              "Timezone",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedTimeZone,
              items:
                  timeZones.map((zone) {
                    return DropdownMenuItem(value: zone, child: Text(zone));
                  }).toList(),
              onChanged: (value) => setState(() => _selectedTimeZone = value!),
            ),
            const SizedBox(height: 24),
            const Text(
              "Number Format",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedNumberFormat,
              items:
                  numberFormats.map((format) {
                    return DropdownMenuItem(value: format, child: Text(format));
                  }).toList(),
              onChanged:
                  (value) => setState(() => _selectedNumberFormat = value!),
            ),
          ],
        ),
      ),
    );
  }
}
