// import 'package:fluto_core/fluto.dart';
// import 'package:fluto_core/src/extension/fluto_log_extension.dart';
// import 'package:fluto_core/src/logger/log_details_page.dart';
// import 'package:fluto_core/src/logger/logger_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class LogViewer extends StatefulWidget {
//   const LogViewer({super.key});
//
//   @override
//   State<LogViewer> createState() => _LogViewerState();
// }
//
// class _LogViewerState extends State<LogViewer> {
//   // late FlutoLoggerProvider _flutoLoggerProvider;
//   final TextEditingController _logSearchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((time) {
//       setState(() {
//         _flutoLoggerProvider =
//             Provider.of<FlutoLoggerProvider>(context, listen: false);
//         _flutoLoggerProvider.syncLocalLogs();
//       });
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Consumer<FlutoLoggerProvider>(
//           builder: (context,flutoLoggerProvider,_) {
//             return Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: Theme.of(context).secondaryHeaderColor,
//                 ),
//               ),
//               child: TextField(
//                 onChanged: (value) {
//                   flutoLoggerProvider.onSearchLogs(logMessage: value);
//                 },
//                 controller: _logSearchController,
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.all(10),
//                   suffixIcon: _logSearchController.text.isNotEmpty
//                       ? Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: InkWell(
//                             onTap: () {
//                               _logSearchController.clear();
//                               flutoLoggerProvider.clearSearch();
//                             },
//                             child: const Icon(
//                               Icons.clear,
//                               size: 25,
//                             ),
//                           ),
//                         )
//                       : const IgnorePointer(),
//                   border: InputBorder.none,
//                   hintText: "Search ${flutoLoggerProvider.selectedLogType.name} logs",
//                 ),
//               ),
//             );
//           }
//         ),
//         actions: [
//           PopupMenuButton<FlutoLogType>(
//             icon: const Icon(Icons.filter_list),
//             padding: const EdgeInsets.symmetric(
//               horizontal: 10,
//             ),
//             onSelected: (FlutoLogType logType) {
//               _flutoLoggerProvider.selectLogType = logType;
//             },
//             itemBuilder: (BuildContext context) {
//               return FlutoLogType.values.map((logType) {
//                 return PopupMenuItem<FlutoLogType>(
//                   value: logType,
//                   child: Row(
//                     children: [
//                       Radio(
//                         groupValue: _flutoLoggerProvider.selectedLogType,
//                         value: logType,
//                         onChanged: (value) {
//                           _flutoLoggerProvider.selectLogType = logType;
//                           Navigator.pop(context);
//                         },
//                       ),
//                       Text(
//                         logType.toString().split('.').last,
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList();
//             },
//           ),
//         ],
//       ),
//       body: Consumer<FlutoLoggerProvider>(
//         builder: (context, logProvider, child) {
//           final logs = logProvider.getAllLogs();
//           return Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextButton(
//                       onPressed: () async {
//                         logProvider.showPicker(context,_logSearchController);
//                       },
//                       child: Text(
//                         logProvider.dateTimeRange != null
//                             ? (logProvider.dateTimeRange.dateRangeString)
//                             : "Select Date Range",
//                         style: Theme.of(context).textTheme.titleMedium,
//                       )),
//                   if (logProvider.dateTimeRange != null)
//                     IconButton(
//                       onPressed: () {
//                         logProvider.clearDateRange(
//                           logMessage: _logSearchController.text,
//                         );
//                       },
//                       icon: const Icon(Icons.clear),
//                     )
//                   else
//                     IconButton(
//                       onPressed: () {
//                         logProvider.showPicker(context,_logSearchController);
//                       },
//                       icon: const Icon(Icons.date_range),
//                     )
//                 ],
//               ),
//               Expanded(
//                 child: LogsTab(
//                   logs: logs,
//                   logType: logProvider.selectedLogType,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _flutoLoggerProvider.clearLogs();
//         },
//         child: const Text(
//           "Clear",
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
//
// class LogsTab extends StatelessWidget {
//   final List<FlutoLogModel> logs;
//   final FlutoLogType logType;
//
//   const LogsTab({
//     super.key,
//     required this.logs,
//     required this.logType,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (logs.isEmpty) {
//       return Center(
//         child: Text("No ${logType.name} logs found"),
//       );
//     }
//     return Consumer<FlutoLoggerProvider>(
//       builder: (context, state, _) {
//         return ListView.builder(
//           key: ValueKey(logs.length),
//           itemCount: logs.length,
//           itemBuilder: (context, index) {
//             final log = logs[index];
//             return log.canShow
//                 ? Dismissible(
//                     background: const ColoredBox(color: Colors.red),
//                     onDismissed: (direction) {
//                       state.removeLog(log);
//                     },
//                     key: ValueKey(log.logTime),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       child: ListTile(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(7),
//                         ),
//                         onTap: () {
//                           showLogDetailsDialog(
//                             context: context,
//                             flutoLog: log,
//                           );
//                         },
//                         title: Text(
//                           log.logMessage,
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         subtitle: Text(log.getFormattedLogTime),
//                         tileColor: Theme.of(context).focusColor,
//                       ),
//                     ),
//                   )
//                 : const IgnorePointer();
//           },
//         );
//       },
//     );
//   }
// }
