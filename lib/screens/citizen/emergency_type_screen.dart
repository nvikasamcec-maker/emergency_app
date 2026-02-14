import 'package:flutter/material.dart';

class EmergencyTypeScreen extends StatelessWidget {
  const EmergencyTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      "❤️ Cardiac",
      "🚗 Accident",
      "🩸 Trauma",
      "🤰 Maternity",
      "⚕️ General",
      "❓ Other",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Type")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: types.length,
        itemBuilder: (_, i) {
          return Card(
            child: ListTile(
              title: Text(types[i]),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
