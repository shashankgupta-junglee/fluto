import 'package:flutter/material.dart';

class ChangeFlavourScreen extends StatefulWidget {
  const ChangeFlavourScreen({
    super.key,
    required this.router,
    required this.config,
  });

  final ChangeFlavourRouter router;
  final ChangeFlavourConfig config;

  @override
  State<ChangeFlavourScreen> createState() => _ChangeFlavourScreenState();
}

class _ChangeFlavourScreenState extends State<ChangeFlavourScreen> {
  Future<void> _setValue(String key, String? value) async {
    await widget.router.setValue(key, value);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Change Flavour"),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              await widget.router.restart();
            },
            child: const Text("Restart"),
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Enable/Disable Flavours"),
                  FutureBuilder(
                    future: widget.router.getValue(widget.config.enableFlavourKey),
                    builder: (context, snapshot) {
                      final bool isEnabled = snapshot.data == "true";
                      return Switch.adaptive(
                        value: isEnabled,
                        onChanged: (bool value) async {
                          await _setValue(
                            widget.config.enableFlavourKey,
                            value.toString(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const Text(
                "Change ENV/FLAVOUR",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ...widget.config.flavours.entries.map((element) {
                return FutureBuilder<String?>(
                  future: widget.router.getValue(element.key),
                  builder: (context, snapshot) {
                    return DropdownButton<String>(
                      hint: Text("Select ${element.key}"),
                      items: widget.config.flavours[element.key]
                          ?.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: snapshot.data,
                      onChanged: (String? newValue) async {
                        _setValue(element.key, newValue);
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
  final String enableFlavourKey;

  ChangeFlavourConfig({
    required this.flavours,
    required this.enableFlavourKey,
  });
}

abstract class ChangeFlavourRouter {
  Future<String?> getValue(String value);
  Future<void> setValue(String key, String? value);
  Future<void> restart();
}
