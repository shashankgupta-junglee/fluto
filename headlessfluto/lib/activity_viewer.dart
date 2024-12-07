import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:headlessfluto/provider/supabase_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityViewer extends StatefulWidget {
  const ActivityViewer({super.key});

  @override
  State<ActivityViewer> createState() => _ActivityViewerState();
}

class _ActivityViewerState extends State<ActivityViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SupabaseProvider>(builder: (context, provider, _) {
        return FutureBuilder<List<FileObject>?>(
          future: provider.getUserActivityRecordings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.hasData) {
              if ((snapshot.data ?? []).isEmpty) {
                return const Center(
                  child: Text("No data found"),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      onTap: () async {
                        final url = await provider.retriveUrl(
                          snapshot.data![index].name,
                        );
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: _GifPlayerScreen(
                                url: url,
                              ),
                            );
                          },
                        );
                      },
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }),
    );
  }
}

class _GifPlayerScreen extends StatefulWidget {
  final String url;
  const _GifPlayerScreen({required this.url});
  @override
  State<_GifPlayerScreen> createState() => _GifPlayerScreenState();
}

class _GifPlayerScreenState extends State<_GifPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return GifView.network(
      widget.url,
      height: 400,
      width: 400,
      frameRate: 10,
    );
  }
}
