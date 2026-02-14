import 'package:flutter/material.dart';

class AISeverityScreen extends StatelessWidget {
  const AISeverityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Severity Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Row("Severity Level", "CRITICAL"),
            _Row("Recommended Response", "Immediate Ambulance"),
            _Row("Survival Window", "10–15 minutes"),

            SizedBox(height: 20),
            Text("AI Reasoning", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "Based on emergency type, location, and response time, "
              "this situation requires urgent medical attention.",
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final String value;
  const _Row(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
