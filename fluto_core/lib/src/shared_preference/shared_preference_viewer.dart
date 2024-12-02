import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared_preference_provider.dart';

class SharedPreferencesViewer extends StatefulWidget {
  const SharedPreferencesViewer({Key? key}) : super(key: key);

  @override
  State<SharedPreferencesViewer> createState() =>
      _SharedPreferencesViewerState();
}

class _SharedPreferencesViewerState extends State<SharedPreferencesViewer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SharedPreferencesProvider>(context, listen: false)
          .loadSharedPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shared Preferences Viewer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              Provider.of<SharedPreferencesProvider>(context, listen: false)
                  .clearSharedPreferences();
            },
          )
        ],
      ),
      body: Consumer<SharedPreferencesProvider>(
        builder: (context, provider, child) {
          final data = provider.sharedPrefsData;

          if (data.isEmpty) {
            return const Center(
              child: Text("No shared preferences found."),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final key = data.keys.elementAt(index);
              final value = data[key];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(key),
                  subtitle: Text(value.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<SharedPreferencesProvider>(context,
                              listen: false)
                          .clearSharedPreferences(key: key);
                    },
                  ),
                  onTap: () => _showEditDialog(context, key, value),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, String key, dynamic value) {
    final TextEditingController controller =
        TextEditingController(text: value.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Value for '$key'"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "New Value"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<SharedPreferencesProvider>(context, listen: false)
                    .updateSharedPreference(key, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
