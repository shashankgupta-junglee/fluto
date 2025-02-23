import 'package:flutter/material.dart';

class ChangeFlavourScreen extends StatelessWidget {
  const ChangeFlavourScreen({
    super.key,
    required this.router,
    required this.config,
  });

  final ChangeFlavourRouter router;
  final ChangeFlavourConfig config;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Change Flavour"),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Change ENV/FLAVOUR",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ...config.flavours.entries.map((element) {
                return FutureBuilder<String?>(
                  future: router.getValue(element.key),
                  builder: (context, snapshot) {
                    return DropdownButton<String>(
                      hint: Text("Select ${element.key}"),
                      items: config.flavours[element.key]?.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: snapshot.data,
                      onChanged: (String? newValue) async {
                        await router.setValue(element.key, newValue);
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeFlavourConfig {
  final Map<String, List<String>> flavours;

  ChangeFlavourConfig({required this.flavours});
}

abstract class ChangeFlavourRouter {
  Future<String?> getValue(String value);
  Future<void> setValue(String key, String? value);
}
