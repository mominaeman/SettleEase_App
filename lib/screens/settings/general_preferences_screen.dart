import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/general_preferences_provider.dart';

class GeneralPreferencesScreen extends StatelessWidget {
  const GeneralPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<GeneralPreferencesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('General Preferences')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Default Home Screen Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Default Home Screen'),
                DropdownButton<HomeScreenOption>(
                  value: prefs.defaultHome,
                  items:
                      HomeScreenOption.values.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(
                            option.name[0].toUpperCase() +
                                option.name.substring(1),
                          ),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      prefs.setDefaultHome(newValue);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Auto Login Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Auto Login'),
                Switch(
                  value: prefs.autoLogin,
                  onChanged: prefs.toggleAutoLogin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
