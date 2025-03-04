// /// A storage for device preview user's preferences.
// abstract class FlutoStorage {
//   const FlutoStorage();
//
//   factory FlutoStorage.none() => const NoFlutoStorage();
//
//   Future<bool> save(String data);
//
//   Future<String?> load();
// }
//
// /// A storage that keep preferences only in memory : they are reset on each
// /// fresh start of the app.
// class NoFlutoStorage extends FlutoStorage {
//   const NoFlutoStorage();
//
//   @override
//   Future<String?> load() => Future.value(null);
//
//   @override
//   Future<bool> save(String data) => Future.value(false);
// }
