// screens/settings/theme_appearance_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeAppearanceSettingsScreen extends StatelessWidget {
  const ThemeAppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme & Appearance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Font Size',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            ListTile(
              title: const Text('Small'),
              leading: Radio<FontSizeOption>(
                value: FontSizeOption.small,
                groupValue: themeProvider.fontSize,
                onChanged: (value) => themeProvider.setFontSize(value!),
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<FontSizeOption>(
                value: FontSizeOption.medium,
                groupValue: themeProvider.fontSize,
                onChanged: (value) => themeProvider.setFontSize(value!),
              ),
            ),
            ListTile(
              title: const Text('Large'),
              leading: Radio<FontSizeOption>(
                value: FontSizeOption.large,
                groupValue: themeProvider.fontSize,
                onChanged: (value) => themeProvider.setFontSize(value!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
